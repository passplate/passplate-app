//
//  RecipeTableViewCell.swift
//  PassplateApp
//
//  Created by Summer Ely on 11/5/23.
//

import UIKit

protocol RecipeTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(on cell: RecipeTableViewCell)
}

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var favButton: UIButton!
    
    weak var delegate: RecipeTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func favButtonTapped(_ sender: UIButton) {
           delegate?.didTapFavoriteButton(on: self)
            favButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
       }

}
