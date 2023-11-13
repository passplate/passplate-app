//
//  FavoritesViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 11/13/23.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecipeTableViewCellDelegate {
    
    func didTapFavoriteButton(on cell: RecipeTableViewCell) {
//        var recipeList = retrieveRecipes()
//        let recipeObj = pizzaList[cell.row]
//        context.delete(recipeObj)
//        pizzaList.remove(at:indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        saveContext()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    var favoriteRecipes: [NSManagedObject] = []
    let recipeCellIdentifier = "RecipeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        favoriteRecipes = retrieveRecipes()
    }
    
    func retrieveRecipes() -> [NSManagedObject] {
        // get me an array of saved recipes from core data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeEntity")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            print("Error occurred while retrieving data")
            abort()
        }
        
        return(fetchedResults)!
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
        cell.recipeNameLabel?.text = meal.value(forKey: "strMeal") as? String
        cell.recipeNameLabel?.numberOfLines = 0
//        cell.recipeImageView?.contentMode = .scaleAspectFit
        
        // Using the imageURL from the filtered meal
        if let imageURL = URL(string: meal.value(forKey: "strMealThumb") as! String) {
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
