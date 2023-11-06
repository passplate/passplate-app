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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergenTableView.dataSource = self
        allergenTableView.delegate = self
        fetchUserAllergies()
        nameLabel.text = name
        allergenTableView.reloadData()
            
    }

    @IBAction func addAllergen(_ sender: Any) {
        allergenTableView.reloadData()

    }
    
    @IBAction func logout(_ sender: Any) {
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
    
    func fetchUserAllergies() {
        let uid = Auth.auth().currentUser?.uid
        
        Firestore.firestore().collection("users").document(uid!).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data from Firestore: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                // User document exists, and you can access its data
                if let userData = document.data() {
                    // Access specific fields from userData
                    self.name = userData["name"] as? String
                    self.allergyList = (userData["allergies"] as? [String])!
                    print(self.name)
                    print(self.allergyList)
    
                }
            } else {
                print("User document does not exist in Firestore.")
            }
        }

    }
    
    
    
}
