//
//  SettingsViewController.swift
//  PassplateApp
//
//  Created by Trent Ho on 11/5/23.
//

import UIKit
import Firebase
import FirebaseAuth


protocol SettingsViewControllerDelegate: AnyObject {
    func didChangeFilteredRecipesSetting(to value: Bool)
}


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: SettingsViewControllerDelegate?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var allergenTableView: UITableView!
    @IBOutlet var darkModeSwitch: UISwitch!
    @IBOutlet weak var showFilteredRecipesSwitch: UISwitch!
    var name: String?
    var allergyList: [String] = []
    let logoutSegueIdentifier = "LogoutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
                // Set up the allergenTableView's dataSource and delegate
                allergenTableView.dataSource = self
                allergenTableView.delegate = self
                
                // Set the name label
                nameLabel.text = name
                
                // Fetch user data to populate the allergens list
                fetchUserData()
        
        
                let showFilteredRecipesEnabled = UserDefaults.standard.bool(forKey: "showFilteredRecipesEnabled")
                showFilteredRecipesSwitch.setOn(showFilteredRecipesEnabled, animated: false)
        
                applyTheme() // Apply theme when view loads
        
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
                    self.allergyList = (userData["allergies"] as? [String])!
                    self.allergenTableView.reloadData()
                }
            } else {
                print("User document does not exist in Firestore.")
            }
        }
    }

    @IBAction func addAllergen(_ sender: Any) {
        var allergenToAdd = ""
        let controller = UIAlertController(
        title: "Add Allergy",
        message: "",
        preferredStyle: .alert
        )

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        controller.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "Enter something" } )
        
        controller.addAction(UIAlertAction(title: "OK",
           style: .default,
           handler: {
            (action) in
            allergenToAdd = controller.textFields![0].text!
            print(allergenToAdd)
            self.allergyList.append(allergenToAdd.lowercased())
            self.allergenTableView.reloadData()
            let uid = Auth.auth().currentUser?.uid
            let updatedData: [String: Any] = [
                "name": self.name!,
                "allergies": self.allergyList
            ]
            Firestore.firestore().collection("users").document(uid!).updateData(updatedData)
            
        }))

        present(controller, animated: true)
            
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("Signout worked")
            performSegue(withIdentifier: logoutSegueIdentifier, sender: self) // segue back to the signin screen
        } catch {
            print("Sign out error")
        }
    }
    
    // Handles deletion from both table and data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            _ = allergyList[indexPath.row]
            
            allergyList.remove(at: indexPath.row)
            
            let uid = Auth.auth().currentUser?.uid
            let updatedData: [String: Any] = [
                "name": self.name!,
                "allergies": self.allergyList
            ]
            Firestore.firestore().collection("users").document(uid!).updateData(updatedData)
            

            // Delete the corresponding row from the table view
            allergenTableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allergyCell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = allergyList[row]
        return cell
       
    }
    
    
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
            updateTheme(isDarkMode: sender.isOn)
            UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
        }
        
        private func applyTheme() {
            let darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
            darkModeSwitch.setOn(darkModeEnabled, animated: false)
            updateTheme(isDarkMode: darkModeEnabled)
        }
        
        private func updateTheme(isDarkMode: Bool) {
            // Set user interface style for the current window
            view.window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            
            // Update tab bar and navigation bar appearance for the current window
            updateTabBarAndNavBar(isDarkMode: isDarkMode)
        }
        
        private func updateTabBarAndNavBar(isDarkMode: Bool) {
            // Refresh the appearance of the navigation bar and tab bar
            if let tabBar = self.tabBarController?.tabBar {
                tabBar.barStyle = isDarkMode ? .black : .default
                tabBar.tintColor = isDarkMode ? .white : .systemBlue
            }
            
            if let navBar = self.navigationController?.navigationBar {
                navBar.barStyle = isDarkMode ? .black : .default
                navBar.tintColor = isDarkMode ? .white : .systemBlue
            }
            
            // Trigger a layout update if needed
            setNeedsStatusBarAppearanceUpdate()
        }
    
    
    @IBAction func showFilteredRecipesSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showFilteredRecipesEnabled")
        delegate?.didChangeFilteredRecipesSetting(to: sender.isOn)
    }
    
}
