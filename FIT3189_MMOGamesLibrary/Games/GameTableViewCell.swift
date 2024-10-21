//
//  GameTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 18/4/2023.
//  Cell for each game detail
// thumbnail, title, genre, and release date

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
