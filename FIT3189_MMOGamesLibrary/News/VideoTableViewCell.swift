//
//  VideoTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 1/6/2023.
//  Video table view cell, using webkit

import UIKit
import WebKit

class VideoTableViewCell: UITableViewCell {
    @IBOutlet weak var youtubeView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
