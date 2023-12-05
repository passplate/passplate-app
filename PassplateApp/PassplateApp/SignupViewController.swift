//
//  SignupViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 10/12/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode
        
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.textContentType = .oneTimeCode

        // Set delegates for text fields
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    // UITextFieldDelegate method to handle return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Handle tap gesture to dismiss keyboard
    @objc func handleTap() {
        view.endEditing(true)
    }

    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx =
           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",
           emailRegEx)
       return emailPred.evaluate(with: email)
    }
      
    func isValidPassword(_ password: String) -> Bool {
       let minPasswordLength = 6
       return password.count >= minPasswordLength
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Error",
            message: "Required fields are empty",
            preferredStyle: .actionSheet
        )
        
        controller.addAction(UIAlertAction (
            title: "Ok",
            style: .default
        ))
        
        
        if (passwordTextField.text!.isEmpty || emailTextField.text!.isEmpty) {
            present(controller, animated: true)
        }
        
        let validPassword = isValidPassword(passwordTextField.text!)
        let validEmail = isValidEmail(emailTextField.text!)
        let passwordsMatch = passwordTextField.text! == confirmPasswordTextField.text!

        if (!validEmail) {
            controller.message = "Enter a valid email address"
            present(controller, animated: true)
            
        } else if (!validPassword) {
            controller.message = "Password of at least 6 characters"
            present(controller, animated: true)
            
        } else if (!passwordsMatch) {
            controller.message = "Passwords do not match"
            present(controller, animated: true)
        }
        
        if (validPassword && validEmail && passwordsMatch) {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult,error) in
                if let error = error as NSError? {
                    print("Error creating user: \(error.localizedDescription)")
                    controller.message = "Error creating user"
                    self.present(controller, animated: true)
                } else {
                    let uid = authResult?.user.uid
                    let allergyList: [String] = []
                    let userData: [String: Any] = [
                        "name": self.nameTextField.text!,
                        "allergies": allergyList
                    ]
                    Firestore.firestore().collection("users").document(uid!).setData(userData)
                    self.performSegue(withIdentifier: "SignupSegue", sender: self)
                    self.emailTextField.text = nil
                    self.passwordTextField.text = nil
                }
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
