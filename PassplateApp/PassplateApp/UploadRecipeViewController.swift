//
//  UploadRecipeViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 12/3/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class UploadRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countryTextView: UITextField!
    @IBOutlet weak var cookingInstructionsTextView: UITextView!
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    let uid = Auth.auth().currentUser?.uid
    var ingredientList: [String] = []
    let defaultImage = UIImage(systemName: "square.and.arrow.up")
    var storageRef: StorageReference!


    override func viewDidLoad() {
        super.viewDidLoad()
            
        recipeImage.image = defaultImage
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self

        cookingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        cookingInstructionsTextView.layer.borderWidth = 1
        storageRef = Storage.storage().reference()

        countryTextView.delegate = self
        recipeNameTextField.delegate = self
        cookingInstructionsTextView.delegate = self

        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
           view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            if text == "\n" {
//                textView.resignFirstResponder()
//                return false
//            }
//            return true
//    }
    
    @IBAction func uploadRecipe(_ sender: Any) {
        let controller = UIAlertController(
            title: "Error",
            message: "Required fields are empty",
            preferredStyle: .actionSheet
        )
        
        controller.addAction(UIAlertAction (
            title: "Ok",
            style: .default
        ))
            
        if recipeNameTextField.text!.isEmpty {
            controller.message = "Enter a recipe name"
            present(controller, animated: true)
        }
        
        else if recipeImage.image?.pngData() == defaultImage?.pngData() {
            controller.message = "Upload a Recipe Image"
            present(controller, animated: true)
        }
        
        else if countryTextView.text!.isEmpty {
            controller.message = "Enter the recipe's country of origin"
            present(controller, animated: true)
        }
        
        else if ingredientList.isEmpty {
            controller.message = "List the recipe's ingredients"
            present(controller, animated: true)
        }
        
        else if cookingInstructionsTextView.text!.isEmpty {
            controller.message = "List the recipe's cooking directions"
            present(controller, animated: true)
        } else {
            let firestore = Firestore.firestore()
            let recipeName = recipeNameTextField.text!
            let recipeImg = recipeImage.image!
            
            let recipeCountryOfOrigin = countryTextView.text!
            let recipeIngredients = ingredientList
            let recipeInstructions = cookingInstructionsTextView.text!
            
            // Create a unique ID for the recipe document
            let recipeID = UUID().uuidString

            // Upload the image to Firebase Storage
            if let imageData = recipeImg.jpegData(compressionQuality: 0.7) {
                let imageRef = storageRef.child("recipe_images/\(recipeID).png")
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/png"
                
                imageRef.putData(imageData, metadata: metadata) { (_, error) in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        // Handle the error
                    } else {
                        // Get the download URL for the uploaded image
                        imageRef.downloadURL { (url, error) in
                            if let error = error {
                                print("Error getting download URL: \(error.localizedDescription)")
                                // Handle the error
                            } else {
                                // Save the recipe details along with the image URL in Firestore
                                let uploadedRecipeDict: [String: Any] = [
                                    "recipeId": recipeID,
                                    "recipeName": recipeName,
                                    "recipeImageURL": url?.absoluteString ?? "",
                                    "recipeCountryOfOrigin": recipeCountryOfOrigin,
                                    "recipeIngredients": recipeIngredients,
                                    "recipeInstructions": recipeInstructions
                                ]
                                
                                firestore.collection("users").document(self.uid!).collection("uploadedRecipes").addDocument(data: uploadedRecipeDict) { error in
                                        if let error = error {
                                            print("Error adding document: \(error)")
                                        } else {
                                            let uploadController = UIAlertController(
                                                title: "Recipe Successfully Uploaded",
                                                message: "View your uploaded recipes in the saved recipes tab!",
                                                preferredStyle: .alert
                                            )
                                            
                                            uploadController.addAction(UIAlertAction (
                                                title: "Ok",
                                                style: .default
                                            ))
                                            self.present(uploadController, animated: true)
                                            self.recipeNameTextField.text = ""
                                            self.recipeImage.image = self.defaultImage
                                            self.countryTextView.text = ""
                                            self.ingredientList = []
                                            self.cookingInstructionsTextView.text = ""
                                            self.ingredientsTableView.reloadData()
                                        }
                                }
                            }
                        }
                    }
                }
            }            
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = ingredientList[row]
        return cell
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        let controller = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        controller.addAction(photoLibraryAction)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }
        controller.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
           guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
               print("Source type \(sourceType) is not available.")
               return
           }
           
           let picker = UIImagePickerController()
           picker.sourceType = sourceType
           picker.delegate = self
           picker.allowsEditing = false
           
           present(picker, animated: true, completion: nil)
       }
       
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let pickedImage = info[.originalImage] as? UIImage {
               recipeImage.image = pickedImage
           }
           
           dismiss(animated: true, completion: nil)
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
       }
    
    @IBAction func addIngredient(_ sender: Any) {
        var ingredientToAdd = ""
        let controller = UIAlertController(
        title: "Add Ingredient",
        message: "Include the quanitity",
        preferredStyle: .alert
        )

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        controller.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "ex: 1 cup sugar" } )
        
        controller.addAction(UIAlertAction(title: "OK",
           style: .default,
           handler: {
            (action) in
            ingredientToAdd = controller.textFields![0].text!
            self.ingredientList.append(ingredientToAdd)
            self.ingredientsTableView.reloadData()
        }))

        present(controller, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentSize()
    }

    func updateScrollViewContentSize() {
        scrollView.contentSize = CGSizeMake(320, 1150);
    }
    
    // Handles deletion from both table and data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            _ = ingredientList[indexPath.row]
            
            ingredientList.remove(at: indexPath.row)

            // Delete the corresponding row from the table view
            ingredientsTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
