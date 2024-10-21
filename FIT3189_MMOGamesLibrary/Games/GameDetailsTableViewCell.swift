//
//  GameDetailsTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  Cell for games detail
//  show all the related information of the game

import UIKit

class GameDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var websiteLinkLabel: UILabel!
    @IBOutlet weak var osLabel: UILabel!
    @IBOutlet weak var processorLabel: UILabel!
    @IBOutlet weak var memoryLabel: UILabel!
    @IBOutlet weak var graphicsLabel: UILabel!
    @IBOutlet weak var storageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
