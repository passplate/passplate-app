//
//  ViewController.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    var recipes: Recipes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call your API here
        // fetchUserData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.recipes = Recipes(count: nil, next: nil, previous: nil, meals: [])
        super.init(coder: aDecoder)
    }

       
    @IBAction func buttonPressed(_ sender: UIButton) {
        fetchSearchResults(searchVal: textField.text!)
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
                    self.recipes.meals.forEach { recipe in print(recipe) }
                } catch {
                    print("Failed to load: \(error)")
                }

            }

        }
        
        task.resume()
    }
    
  }
