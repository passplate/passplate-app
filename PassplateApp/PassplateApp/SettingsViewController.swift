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
        nameLabel.text = name
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

    
    
    
}
