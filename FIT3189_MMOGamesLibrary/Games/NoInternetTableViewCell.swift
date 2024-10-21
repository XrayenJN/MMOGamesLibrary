//
//  NoInternetTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 9/6/2023.
//  Cell for showing that there is no internet (No internet Icon)

import UIKit

class NoInternetTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
