//
//  GameScreenshotTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  Table Cell for Screenshot, just consist of the UIImageView

import UIKit

class GameScreenshotTableViewCell: UITableViewCell {
    @IBOutlet weak var screenshotView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
