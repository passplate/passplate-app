//
//  RecipeViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/16/23.
//

import UIKit
import Firebase
import FirebaseAuth

class RecipeViewController: UIViewController, UITableViewDataSource {
    
    var recipe: Recipe
    var fullRecipe: FullRecipe
    
    // Measurement, ingredient
    var ingredients: [(String, String)] = []

    var allergenIngredients: [String] = []
    var userAllergens: [String] = []
    var userName: String = ""
    let settingsSegueIdentifier = "RecipeToSettingsSegue"
    


    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        recipeLabel.text = recipe.strMeal
        fetchUserData()
        
        recipeImage.layer.cornerRadius = 20
        recipeImage.clipsToBounds = true

        // Load image into UIImageView
        if let imageURL = URL(string: recipe.strMealThumb) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.recipeImage.image = image
                    }
                }
            }
        }
        
        fetchRecipeResults(idMeal: recipe.idMeal)
        categoryLabel.text = fullRecipe.strCategory
        // create and present alert if allergy list contains any of the user's allergies
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == settingsSegueIdentifier,
           let destination = segue.destination as? SettingsViewController {
            // When the user goes to create a new pizza, these fields should not be populated.
            destination.name = userName
            destination.allergyList = userAllergens
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentSize()
    }
    
    func updateScrollViewContentSize() {
        let screenHeight = UIScreen.main.bounds.size.height
        let contentHeight = max(screenHeight * 0.8, instructionsLabel.frame.origin.y + instructionsLabel.frame.size.height + 16)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentHeight)
    }
    
    func isAllergenSubstring(ingredient: String) -> Bool {
        var substringFound = false
        for allergen in userAllergens {
            if ingredient.contains(allergen) {
                substringFound = true
            }
        }
        return substringFound
    }
    
    func fetchRecipeResults(idMeal: String) {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" + idMeal)

        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        print("request: \(request)")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Convert HTTP Response Data to String
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
                    print("reciperesponse = \(recipeResponse)")
                    if let fullRecipe = recipeResponse.meals?.first {
                        self.fullRecipe = fullRecipe
                        for i in 1...20 {
                            let ingredientKey = "strIngredient\(i)"
                            let measureKey = "strMeasure\(i)"
                            
                            let mirror = Mirror(reflecting: fullRecipe)
                            
                            for (property, value) in mirror.children {
                                if let property = property, property == ingredientKey, let ingredient = value as? String,
                                   let measureValue = mirror.children.first(where: { ($0.label) == measureKey })?.value as? String,
                                   !ingredient.isEmpty && !measureValue.isEmpty {
                                    // need to have a way to account for plurals (ex: tomatoes vs tomato)
                                    if self.userAllergens.contains(ingredient.lowercased()) {
                                        self.allergenIngredients.append(ingredient)
                                    } else if self.isAllergenSubstring(ingredient: ingredient.lowercased()) {
                                        self.allergenIngredients.append(ingredient)
                                    }
                                    self.ingredients.append((measureValue, ingredient))
                                }
                            }
                        }


                        // Update Labels with full recipe results
                        DispatchQueue.main.async {
                            self.categoryLabel.text = "Category: \(self.fullRecipe.strCategory)"
                            self.instructionsLabel.numberOfLines = 0
                            self.instructionsLabel.lineBreakMode = .byWordWrapping
                            self.instructionsLabel.text = "Instructions: \(self.fullRecipe.strInstructions)"
                            self.instructionsLabel.sizeToFit()
                            self.tableView.reloadData()
                            print("self.ingredients")
                            print(self.ingredients)
                            
                            print("allergen count: \(self.allergenIngredients.count)")
                            if !self.allergenIngredients.isEmpty {
                                let controller = UIAlertController(
                                title: "Allergens present",
                                message: "recipe contains: \(self.allergenIngredients.joined(separator: ","))",
                                preferredStyle: .alert
                                )

                                controller.addAction(UIAlertAction(title: "Ok", style: .default))
                                print("should reach here")
                                self.present(controller, animated: true)
                            }
                            
                        }
                    } else {
                        print("No recipes found in the response.")
                    }
                } catch {
                    print("Failed to load: \(error)")
                }
            }
        }

        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        
        let ingredientMeasure = ingredients[indexPath.row]
        if allergenIngredients.contains(ingredientMeasure.1) {
            cell.textLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .black
            if self.traitCollection.userInterfaceStyle == .dark {
                // The app is in dark mode
                cell.textLabel?.textColor = .white
            }
        }
        cell.textLabel?.text = "\(ingredientMeasure.0) \(ingredientMeasure.1)"
//        cell.detailTextLabel?.text = ingredientMeasure.1
        
        return cell
    }


    func fetchUserData() {
        let uid = Auth.auth().currentUser?.uid
        Firestore.firestore().collection("users").document(uid!).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data from Firestore: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                // User document exists, and you can access its data
                if let userData = document.data() {
                    // Access specific fields from userData
                    self.userName = (userData["name"] as? String)!
                    self.userAllergens = (userData["allergies"] as? [String])!
                }
            } else {
                print("User document does not exist in Firestore.")
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.recipe = Recipe(idMeal: "", strMeal: "", strMealThumb: "")
        self.fullRecipe = FullRecipe.init(idMeal: "", strMeal: "", strDrinkAlternate: "", strCategory: "", strArea: "", strInstructions: "", strMealThumb: "", strTags: "", strYoutube: "", strIngredient1: "", strIngredient2: "", strIngredient3: "", strIngredient4: "", strIngredient5: "", strIngredient6: "", strIngredient7: "", strIngredient8: "", strIngredient9: "", strIngredient10: "", strIngredient11: "", strIngredient12: "", strIngredient13: "", strIngredient14: "", strIngredient15: "", strIngredient16: "", strIngredient17: "", strIngredient18: "", strIngredient19: "", strMeasure1: "", strMeasure2: "", strMeasure3: "", strMeasure4: "", strMeasure5: "", strMeasure6: "", strMeasure7: "", strMeasure8: "", strMeasure9: "", strMeasure10: "", strMeasure11: "", strMeasure12: "", strMeasure13: "", strMeasure14: "", strMeasure15: "", strMeasure16: "", strMeasure17: "", strMeasure18: "", strMeasure19: "", strMeasure20: "", strSource: "", strImageSource: "", strCreativeCommonsConfirmed: "", dateModified: "")
        super.init(coder: aDecoder)
    }


}
