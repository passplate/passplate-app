//
//  UploadRecipeViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 12/3/23.
//

import UIKit
import Firebase
import FirebaseAuth

class UploadRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countryTextView: UITextField!
    @IBOutlet weak var cookingInstructionsTextView: UITextView!
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    let uid = Auth.auth().currentUser?.uid
    var ingredientList: [String] = []
    let defaultImage = UIImage(systemName: "square.and.arrow.up")

    override func viewDidLoad() {
        super.viewDidLoad()
            
        recipeImage.image = defaultImage
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self

        cookingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        cookingInstructionsTextView.layer.borderWidth = 1
        
    }
    
    
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
        
        if recipeImage.image == defaultImage {
            controller.message = "Recipe Image field is empty"
            present(controller, animated: true)
        }
    
        if recipeNameTextField.text!.isEmpty {
            controller.message = "Recipe Name field is empty"
            present(controller, animated: true)
        }
        
        if countryTextView.text!.isEmpty {
            controller.message = "Country of origin field is empty"
            present(controller, animated: true)
        }
        
        if ingredientList.isEmpty {
            controller.message = "Ingredient List is empty"
            present(controller, animated: true)
        }
        
        if cookingInstructionsTextView.text!.isEmpty {
            controller.message = "Cooking directions field is empty"
            present(controller, animated: true)
        }

                    
        let firestore = Firestore.firestore()
        let uploadedRecipeDict: [String: Any] = [
            "recipeName": recipeNameTextField.text!,
            "recipeImage": recipeImage.image!,
            "recipeCountryOfOrigin": countryTextView.text!,
            "recipeIngredients": ingredientList,
            "recipeInstructions": cookingInstructionsTextView.text!
        ]
        
        firestore.collection("users").document(uid!).collection("uploadedRecipes").addDocument(data: uploadedRecipeDict) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
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
            print(ingredientToAdd)
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
        scrollView.contentSize = CGSizeMake(320, 1000);
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
