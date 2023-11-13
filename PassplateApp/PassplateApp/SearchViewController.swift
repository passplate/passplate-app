//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData

let context = appDelegate.persistentContainer.viewContext
let appDelegate = UIApplication.shared.delegate as! AppDelegate

struct AllergenAwareRecipe {
    let recipe: Recipe
    let containsAllergens: Bool
}

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate,  UITableViewDataSource {
    
    @IBOutlet var searchBar: UISearchBar!
    var inputSearchText: String
    @IBOutlet weak var tableView: UITableView!

    var recipes: Recipes
    let recipeCellIdentifier = "RecipeCell"
    let recipeSegueIdentifier = "RecipeSegueIdentifier"
    let settingsSegueIdentifier = "SearchToSettingsSegue"
    var userAllergens: [String] = []
    var userName: String = ""
    var filteredMeals: [Recipe] = []
    let dietaryRestrictions = DietaryRestrictions.shared.restrictions
    var showFilteredRecipes: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.text = inputSearchText
        fetchUserData()
        fetchSearchResults(searchVal: inputSearchText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.recipes = Recipes(count: 0, next: nil, previous: nil, meals: [])
        self.inputSearchText = ""
        super.init(coder: aDecoder)
    }

       
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        fetchSearchResults(searchVal: searchText)
    }
    
    func fetchSearchResults(searchVal: String) {
        let encodedArea = searchVal.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?a=\(encodedArea)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }

        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error took place \(error)")
                return
            }

            guard let data = data else {
                print("Did not receive data")
                return
            }

            do {
                let decoder = JSONDecoder()
                let recipesResponse = try decoder.decode(Recipes.self, from: data)

                guard let meals = recipesResponse.meals else {
                    DispatchQueue.main.async {
                        print("No meals found for the area.")
                    }
                    return
                }

                var allMeals = [AllergenAwareRecipe]()
                let fetchGroup = DispatchGroup()

                for meal in meals {
                    fetchGroup.enter()
                    self.fetchFullRecipe(for: meal.idMeal) { fullRecipe in
                        if let fullRecipe = fullRecipe {
                            let allergenCheck = self.mealContainsAllergens(fullRecipe)
                            allMeals.append(AllergenAwareRecipe(recipe: meal, containsAllergens: allergenCheck.containsAllergens))
                            // Print statement for debugging
                            if allergenCheck.containsAllergens {
                                print("Meal with allergens: \(fullRecipe.strMeal), Allergens: \(allergenCheck.detectedAllergens.joined(separator: ", "))")
                            }
                        }
                        fetchGroup.leave()
                    }
                }

                fetchGroup.notify(queue: .main) {
                    if self.showFilteredRecipes {
                        // Show all meals
                        self.filteredMeals = allMeals.map { $0.recipe }
                    } else {
                        // Show only allergen-free meals
                        self.filteredMeals = allMeals.filter { !$0.containsAllergens }.map { $0.recipe }
                    }
                    self.tableView.reloadData()
                }

            } catch {
                DispatchQueue.main.async {
                    print("JSON decoding failed: \(error)")
                }
            }
        }

        task.resume()
    }

    
    func fetchFullRecipe(for idMeal: String, completion: @escaping (FullRecipe?) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(idMeal)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL for meal details.")
            completion(nil)
            return
        }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching meal details: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Did not receive data for meal details")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
                completion(recipeResponse.meals?.first)
            } catch {
                print("Decoding error for meal details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    func mealContainsAllergens(_ meal: FullRecipe) -> (containsAllergens: Bool, detectedAllergens: [String]) {
        var detectedAllergens: [String] = []
        let ingredients = [
            meal.strIngredient1, meal.strIngredient2, meal.strIngredient3, meal.strIngredient4,
            meal.strIngredient5, meal.strIngredient6, meal.strIngredient7, meal.strIngredient8,
            meal.strIngredient9, meal.strIngredient10, meal.strIngredient11, meal.strIngredient12,
            meal.strIngredient13, meal.strIngredient14, meal.strIngredient15, meal.strIngredient16,
            meal.strIngredient17, meal.strIngredient18, meal.strIngredient19
        ].compactMap { $0?.lowercased() }

        for allergen in userAllergens {
            // Check if the allergen is a dietary restriction group
            if let restrictionGroup = dietaryRestrictions[allergen] {
                for ingredient in ingredients {
                    if restrictionGroup.contains(where: { ingredient.contains($0.lowercased()) }) {
                        detectedAllergens.append(allergen)
                        break // Found an allergen, no need to check further
                    }
                }
            } else {
                // Check for the allergen directly in the ingredients
                let normalizedAllergen = allergen.lowercased()
                if ingredients.contains(where: { $0.contains(normalizedAllergen) }) {
                    detectedAllergens.append(allergen)
                }
            }
        }

        return (!detectedAllergens.isEmpty, detectedAllergens)
    }
    

    func singularize(_ word: String) -> String {
        // This is a naive implementation and works on simple cases.
        if word.lowercased().hasSuffix("ies") {
            let index = word.index(word.endIndex, offsetBy: -3)
            return String(word[..<index]) + "y"
        } else if word.lowercased().hasSuffix("es") && !word.lowercased().hasSuffix("sses") {
            let index = word.index(word.endIndex, offsetBy: -2)
            return String(word[..<index])
        } else if word.last == "s" && !word.lowercased().hasSuffix("ss") {
            return String(word.dropLast())
        }
        return word
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recipeSegueIdentifier,
           let destination = segue.destination as? RecipeViewController,
           let recipeIndex = tableView.indexPathForSelectedRow?.row {
            destination.recipe = filteredMeals[recipeIndex]
        } else if segue.identifier == settingsSegueIdentifier,
                  let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.name = userName
            settingsVC.allergyList = userAllergens
            settingsVC.delegate = self // Set SearchViewController as the delegate
        }
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user data from Firestore: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if let userData = document.data() {
                    self.userName = userData["name"] as? String ?? "Unknown"
                    self.userAllergens = userData["allergies"] as? [String] ?? []
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // If needed to refresh the UI based on fetched data
                    }
                }
            } else {
                print("User document does not exist in Firestore.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeals.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recipeCellIdentifier, for: indexPath) as! RecipeTableViewCell
        
        let row = indexPath.row
        let meal = filteredMeals[row]
        cell.recipeNameLabel?.text = meal.strMeal
        cell.recipeNameLabel?.numberOfLines = 0
        cell.recipeImageView?.contentMode = .scaleAspectFit
        
        // Using the imageURL from the filtered meal
        if let imageURL = URL(string: meal.strMealThumb) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.recipeImageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        cell.delegate = self
        return cell
    }

    
    func saveRecipeToCoreData(_ recipe: Recipe) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let recipeEntity = NSEntityDescription.insertNewObject(
            forEntityName: "RecipeEntity",
            into: context)
        recipeEntity.setValue(recipe.idMeal, forKey: "idMeal")
        recipeEntity.setValue(recipe.strMeal, forKey: "strMeal")
        recipeEntity.setValue(recipe.strMealThumb, forKey: "strMealThumb")
        
        saveContext()
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

  }


extension SearchViewController: RecipeTableViewCellDelegate {
    func didTapFavoriteButton(on cell: RecipeTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let recipe = filteredMeals[indexPath.row]
        saveRecipeToCoreData(recipe)
    }
}

extension SearchViewController: SettingsViewControllerDelegate {
    func didChangeFilteredRecipesSetting(to value: Bool) {
        print("Filtered Recipes Switch is now: \(value)")
                showFilteredRecipes = value
                fetchSearchResults(searchVal: searchBar.text ?? "")
    }
}
