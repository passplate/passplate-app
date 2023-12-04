//
//  UploadRecipeViewController.swift
//  PassplateApp
//
//  Created by Annie Prosper on 12/3/23.
//

import UIKit

class UploadRecipeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    

    @IBOutlet weak var countryTextView: UITextField!
    @IBOutlet weak var cookingInstructionsTextView: UITextView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTextView.layer.borderColor = UIColor.lightGray.cgColor
        ingredientsTextView.layer.borderWidth = 1

        cookingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        cookingInstructionsTextView.layer.borderWidth = 1
        
//        cookingInstructionsTextView.text = "Enter Recipe's cooking instructions"
//        cookingInstructionsTextView.textColor = UIColor.lightGray
//
//        ingredientsTextView.text = "Enter Recipe's ingredients"
//        ingredientsTextView.textColor = UIColor.lightGray
    }
    
    
    
    @IBAction func uploadRecipe(_ sender: Any) {
        
    }
    
    @IBAction func uploadImage(_ sender: Any) {
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentSize()
    }

    func updateScrollViewContentSize() {
        let screenHeight = UIScreen.main.bounds.size.height
//        let contentHeight = max(screenHeight * 0.8, instructionsLabel.frame.origin.y + instructionsLabel.frame.size.height + 16)
        scrollView.contentSize = CGSizeMake(320, 940);

//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentHeight)
    }
//

}
