//
//  LoginViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 10/11/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    //CreateAccountSegue
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "SigninSegue", sender: self)
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
            }
        }
        
    }
    
    
    // ERROR MESSAGES:
    // email not found (?) 
    // password incorrect
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // Complete for Beta release
    // Segues to a new screen where user can input their email, and it will prompt them to update their password
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (authResult,error) in
            //            if let error = error as NSError? {
            //                self.errorMessage.text + "\(error.localizedDescription)"
            //            } else {
            // self.errorMessage.text = ""
            //}
        }
        
    }
}
