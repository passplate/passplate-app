//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit
import Firebase
import FirebaseAuth

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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.text = inputSearchText
        fetchSearchResults(searchVal: searchBar.text!)
        fetchUserData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.recipes = Recipes(count: 0, next: nil, previous: nil, meals: [])
        self.inputSearchText = ""
        super.init(coder: aDecoder)
    }

       
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchSearchResults(searchVal: searchBar.text!)
    }

    func fetchSearchResults(searchVal: String) {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?a=" + searchVal)

        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Convert HTTP Response Data to String
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    
                    // Decode into list of Recipes
                    self.recipes = try decoder.decode(Recipes.self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Failed to load: \(error)")
                }

            }

        }
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recipeSegueIdentifier,
           let destination = segue.destination as? RecipeViewController,
           let recipeIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.recipe = recipes.meals[recipeIndex]
        }
        if segue.identifier == settingsSegueIdentifier,
           let destination = segue.destination as? SettingsViewController {
            // When the user goes to create a new pizza, these fields should not be populated.
            destination.name = userName
            destination.allergyList = userAllergens
        }

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.meals.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    // Displays recipe objects in custom cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recipeCellIdentifier, for: indexPath as IndexPath) as! RecipeTableViewCell
        
        let row = indexPath.row
        cell.recipeNameLabel?.text = recipes.meals[row].strMeal
        cell.recipeNameLabel?.numberOfLines = 0
        cell.recipeImageView?.contentMode = .scaleAspectFit
        
        if let imageURL = URL(string: recipes.meals[row].strMealThumb) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.recipeImageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }


    
  }
