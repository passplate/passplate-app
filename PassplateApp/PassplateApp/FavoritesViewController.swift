//
//  FavoritesViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 11/13/23.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecipeTableViewCellDelegate {
    func didTapFavoriteButton(on cell: RecipeTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let recipe = favoriteRecipes[indexPath.row]

        removeRecipeFromFirestore(recipe)
        favoriteRecipes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var favoriteRecipes: [Recipe] = []
    var uploadedRecipes: [UploadedRecipe] = []
    let recipeCellIdentifier = "RecipeCell"
    let recipeSegueIdentifier = "RecipeSegueIdentifier"
    let uploadedRecipeCellIdentifier = "UploadedRecipeCell"
    let uploadRecipeSegueIdentifier = "UploadRecipeSegueIdentifier"
    let segueToSettingsIdentifier = "FavoritesToSettingsSegue"
    var selectedTab = "Favorites"
    var userAllergens: [String] = []
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        tableView.delegate = self
        tableView.dataSource = self
        retrieveFavoritesFromFirestore()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recipeSegueIdentifier,
           let destination = segue.destination as? RecipeViewController,
           let recipeIndex = tableView.indexPathForSelectedRow?.row {
                destination.recipe = favoriteRecipes[recipeIndex]
        }
        if segue.identifier == uploadRecipeSegueIdentifier,
           let destination = segue.destination as? SingleUploadedRecipeViewController,
           let recipeIndex = tableView.indexPathForSelectedRow?.row {
                destination.uploadedRecipe = uploadedRecipes[recipeIndex]
        }
        if segue.identifier == segueToSettingsIdentifier,
           let destination = segue.destination as? SettingsViewController {
               destination.name = userName
               destination.allergyList = userAllergens
        }
        
    }
    
    func retrieveFavoritesFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
               print("No user is currently logged in.")
               return
           }
        Firestore.firestore().collection("users").document(uid).collection("favorites").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.favoriteRecipes.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // Create a Recipe object from document data and add it to favoriteRecipes
                    let data = document.data()
                    let recipe = Recipe(idMeal: data["idMeal"] as? String ?? "", strMeal: data["strMeal"] as? String ?? "", strMealThumb: data["strMealThumb"] as? String ?? "")
                    self.favoriteRecipes.append(recipe)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func retrieveUploadedRecipesFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
               print("No user is currently logged in.")
               return
           }
        Firestore.firestore().collection("users").document(uid).collection("uploadedRecipes").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.uploadedRecipes.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // Create a Recipe object from document data and add it to favoriteRecipes
                    let data = document.data()
                    let uploadedRecipe = UploadedRecipe(recipeId: data["recipeId"] as? String ?? "", recipeName: data["recipeName"] as? String ?? "", recipeImage: data["recipeImage"] as? String ?? "", recipeCountryOfOrigin: data["recipeCountryOfOrigin"] as? String ?? "", recipeInstructions: data["recipeInstructions"] as? String ?? "", recipeIngredients: data["recipeIngredients"] as? [String] ?? [])
                    self.uploadedRecipes.append(uploadedRecipe)
                }
                self.tableView.reloadData()
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveFavoritesFromFirestore()
    }
    
    @IBAction func onSegmentChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedTab = "Favorites"
            retrieveFavoritesFromFirestore()
            self.tableView.reloadData()

        case 1:
            self.selectedTab = "Uploaded Recipes"
            print("UPLOAD RECIPE COUNT \(uploadedRecipes.count)")
            retrieveUploadedRecipesFromFirestore()
            self.tableView.reloadData()

        default:
            self.selectedTab = "Favorites"
            retrieveFavoritesFromFirestore()
            self.tableView.reloadData()

        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == "Uploaded Recipes" {
            return uploadedRecipes.count
        }
        return favoriteRecipes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTab == "Uploaded Recipes" {
            let cell = tableView.dequeueReusableCell(withIdentifier: uploadedRecipeCellIdentifier, for: indexPath) as! UploadedRecipeTableViewCell
            
            let row = indexPath.row
            let recipe = uploadedRecipes[row]
            cell.uploadNameLabel?.text = recipe.recipeName
            cell.uploadNameLabel?.numberOfLines = 0
            
            
            let storage = Storage.storage()
            let imageRef = storage.reference().child("recipe_images/\(recipe.recipeId).png")

            // Download the data from the StorageReference
            imageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    // Handle the error
                } else {
                    // Successfully downloaded the data, create a UIImage
                    if let imageData = data, let image = UIImage(data: imageData) {
                        // Now you can use 'image' as your UIImage
                        // For example, you might set it to an image view
                        cell.uploadImageView?.image = image
                        cell.setNeedsLayout()
                    } else {
                        print("Error creating UIImage from data.")
                        // Handle the error
                    }
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: recipeCellIdentifier, for: indexPath) as! RecipeTableViewCell
        
        let row = indexPath.row
        let meal = favoriteRecipes[row]
        cell.recipeNameLabel?.text = meal.strMeal
        cell.recipeNameLabel?.numberOfLines = 0
        cell.favButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
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

}
