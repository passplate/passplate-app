//
//  UploadedRecipeTableViewCell.swift
//  PassplateApp
//
//  Created by Annie Prosper on 12/4/23.
//

import UIKit

class UploadedRecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var uploadNameLabel: UILabel!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.tintColor = .cyan
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
