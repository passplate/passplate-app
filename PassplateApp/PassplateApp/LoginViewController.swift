///Users/annieprosper/Documents/passplate-app/PassplateApp/PassplateApp/SignupViewController.swift
//  LoginViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 10/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // SigninSegue
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // Complete for Beta release
    // Segues to a new screen where user can input their email, and it will prompt them to update their password
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Error",
            message: "Error logging user in",
            preferredStyle: .actionSheet
        )
        
        controller.addAction(UIAlertAction (
            title: "Ok",
            style: .default
        ))
        
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {
            (authResult,error) in
                if let error = error as NSError? {
                    print("Error logging user in: \(error.localizedDescription)")
                    print(self.emailTextField.text!)
                    print(self.passwordTextField.text!)
                    self.present(controller, animated: true)
                } else {
                    self.performSegue(withIdentifier: "SigninSegue", sender: self)
                    self.emailTextField.text = nil
                    self.passwordTextField.text = nil
                }
        }
        createUserDoc()
    }
    
    func createUserDoc() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }

        let userDocRef = Firestore.firestore().collection("users").document(uid)

        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User document already exists.")
            } else {
                print("User document does not exist. Creating one.")
                userDocRef.setData(["name": "Default Name", "allergies": []]) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("User document successfully created.")
                    }
                }
            }
        }
    }

}
