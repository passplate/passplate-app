////
////  SingleUploadedRecipeViewController.swift
////  PassplateApp
////
////  Created by Annie Prosper on 12/4/23.
////
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class SingleUploadedRecipeViewController: UIViewController, UITableViewDataSource {
    
    var uploadedRecipe: UploadedRecipe?
    // Measurement, ingredient
    
    var allergenIngredients: [String] = []
    var userAllergens: [String] = []
    var userName: String = ""
    let settingsSegueIdentifier = "UploadRecipeToSettingsSegue"
    
    
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
        recipeLabel.text = uploadedRecipe?.recipeName
        fetchUserData()
        
        recipeImage.layer.cornerRadius = 20
        recipeImage.clipsToBounds = true
        
        // sets the recipe image
        let storage = Storage.storage()
        let imageRef = storage.reference().child("recipe_images/\(uploadedRecipe!.recipeId).png")
        
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
                    self.recipeImage.image = image
                    self.recipeImage.setNeedsLayout()
                } else {
                    print("Error creating UIImage from data.")
                    // Handle the error
                }
            }
        }
        
        fetchAllergens()
        categoryLabel.text = uploadedRecipe?.recipeCountryOfOrigin
        instructionsLabel.text = uploadedRecipe?.recipeInstructions
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
    
    func fetchAllergens() {
        
        for i in 0...(uploadedRecipe!.recipeIngredients.count - 1) {
            let ingredient = uploadedRecipe!.recipeIngredients[i]
            if !ingredient.isEmpty{
                // need to have a way to account for plurals (ex: tomatoes vs tomato)
                if self.userAllergens.contains(ingredient.lowercased()) {
                    self.allergenIngredients.append(ingredient)
                } else if self.isAllergenSubstring(ingredient: ingredient.lowercased()) {
                    self.allergenIngredients.append(ingredient)
                }
            }
        }
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return uploadedRecipe!.recipeIngredients.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
            
            let ingredient = uploadedRecipe!.recipeIngredients[indexPath.row]
            if allergenIngredients.contains(ingredient) {
                cell.textLabel?.textColor = .red
            } else {
                cell.textLabel?.textColor = .black
                if self.traitCollection.userInterfaceStyle == .dark {
                    // The app is in dark mode
                    cell.textLabel?.textColor = .white
                }
            }
            cell.textLabel?.font = UIFont(name: "Poppins", size: 16.0)
            cell.textLabel?.text = "\(ingredient)"
            
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
