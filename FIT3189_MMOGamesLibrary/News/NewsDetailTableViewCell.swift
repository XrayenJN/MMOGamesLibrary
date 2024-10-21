//
//  NewsDetailTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  News Details VC , just showing the title, short description, and article content
//  It doesn't need any thumbnail because in the article content, we already have the image.

import UIKit
import WebKit

class NewsDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shortDescLabel: UILabel!
    @IBOutlet weak var articleContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
