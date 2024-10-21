//
//  UserAuthTableViewCell.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  If user has logged in, show the saved games and wishlist and also logout button

import UIKit

class UserAuthTableViewCell: UITableViewCell {
    weak var firebaseController: FirebaseProtocol?
    
    @IBAction func logoutButton(_ sender: Any) {
        firebaseController?.logout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
