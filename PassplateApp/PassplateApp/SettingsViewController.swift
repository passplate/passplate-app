//
//  SettingsViewController.swift
//  PassplateApp
//
//  Created by Trent Ho on 11/5/23.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var allergenTableView: UITableView!
    var name: String?
    var allergyList: [String] = []
    let logoutSegueIdentifier = "LogoutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergenTableView.dataSource = self
        allergenTableView.delegate = self
        nameLabel.text = name
        fetchUserData()
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

    
    
    
}
