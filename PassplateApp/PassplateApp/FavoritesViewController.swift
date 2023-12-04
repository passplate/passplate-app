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

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecipeTableViewCellDelegate {
    
    func didTapFavoriteButton(on cell: RecipeTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let recipe = favoriteRecipes[indexPath.row]

        removeRecipeFromFirestore(recipe)
        favoriteRecipes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    
    @IBOutlet weak var tableView: UITableView!
    var favoriteRecipes: [Recipe] = []
    let recipeCellIdentifier = "RecipeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        retrieveFavoritesFromFirestore()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveFavoritesFromFirestore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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


}
