//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var recipes: Recipes
    let textCellIdentifier = "TextCell"
    let recipeSegueIdentifier = "RecipeSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.recipes = Recipes(count: 0, next: nil, previous: nil, meals: [])
        super.init(coder: aDecoder)
    }

       
    @IBAction func buttonPressed(_ sender: UIButton) {
        fetchSearchResults(searchVal: textField.text!)
//        tableView.reloadData()
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.meals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = recipes.meals[row].strMeal
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.contentMode = .scaleAspectFit
        
        if let imageURL = URL(string: recipes.meals[row].strMealThumb) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }

    
  }
