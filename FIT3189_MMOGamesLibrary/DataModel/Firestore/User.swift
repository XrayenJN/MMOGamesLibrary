//
//  User.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 14/5/2023.
//  Data model to hold the save games and wishlist for each user
// is used to integrate it with the firebase

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    var savedGames = [Int]()
    var wishlist = [Int]()
}
