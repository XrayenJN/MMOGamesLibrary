//
//  GamesData.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 18/4/2023.
//  Retrieve the Game attribute from API

import UIKit

// Enum for the error
enum GamesDataError: Error {
    case invalidThumbnailURL
}

// Games Object
class GamesData: NSObject, Decodable {
    var id: Int?
    var title: String?
    var thumbnail: String?
    var shortDescription: String?
    var gameURL: String?
    var genre: String?
    var platform: String?
    var publisher: String?
    var developer: String?
    var releaseDate: String?
    var profileURL: String?

    // used for downloading thumbnail
    var thumbnailImage: UIImage?
    var thumbnailIsDownloading: Bool = false
    var thumbnailShown: Bool = true
    
    // Break down the information that we get form API
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: GameKeys.self)

        id = try rootContainer.decode(Int.self, forKey: .id)
        title = try rootContainer.decode(String.self, forKey: .title)
        thumbnail = try rootContainer.decode(String.self, forKey: .thumbnail)
        shortDescription = try rootContainer.decode(String.self, forKey: .shortDescription)
        gameURL = try rootContainer.decode(String.self, forKey: .gameURL)
        genre = try rootContainer.decode(String.self, forKey: .genre)
        platform = try rootContainer.decode(String.self, forKey: .platform)
        publisher = try rootContainer.decode(String.self, forKey: .publisher)
        developer = try rootContainer.decode(String.self, forKey: .developer)
        releaseDate = try rootContainer.decode(String.self, forKey: .releaseDate)
        profileURL = try rootContainer.decode(String.self, forKey: .profileURL)
    }
}

private enum GameKeys: String, CodingKey {
    case id
    case title
    case thumbnail
    case shortDescription = "short_description"
    case gameURL = "game_url"
    case genre
    case platform
    case publisher
    case developer
    case releaseDate = "release_date"
    case profileURL = "profile_url"
}
