//
//  GameData.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 8/5/2023.
//  Game Data object for individual game, it has more detail information
//  such as the screenshot, os and stuff

import UIKit

//
enum GameDataError: Error {
    case invalidScreenshotURL
}

// game data object
class GameData: NSObject, Decodable {
    var id: Int?
    var title: String?
    var thumbnail: String?
    var status: String?
    var shortDescription: String?
    var gameURL: String?
    var genre: String?
    var platform: String?
    var publisher: String?
    var developer: String?
    var releaseDate: String?
    var profileURL: String?
    
    var os: String?
    var processor: String?
    var memory: String?
    var graphics: String?
    var storage: String?
    
    var screenshots: [String] = []
    
    // used for downloading thumbnail
    var thumbnailImage: UIImage?
    var thumbnailIsDownloading: Bool = false
    var thumbnailShown: Bool = true
    
    // used for downloading screenshots
    var screenshotID: [Int] = []
    var screenshotImage: [UIImage?] = []
    var screenshotIsDownloading: [Bool] = []
    var screenshotShown: Bool = true
    
    // retrieve it from the API
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: GameKeys.self)

        id = try rootContainer.decode(Int.self, forKey: .id)
        title = try rootContainer.decode(String.self, forKey: .title)
        thumbnail = try rootContainer.decode(String.self, forKey: .thumbnail)
        status = try rootContainer.decode(String.self, forKey: .status)
        shortDescription = try rootContainer.decode(String.self, forKey: .shortDescription)
        gameURL = try rootContainer.decode(String.self, forKey: .gameURL)
        genre = try rootContainer.decode(String.self, forKey: .genre)
        platform = try rootContainer.decode(String.self, forKey: .platform)
        publisher = try rootContainer.decode(String.self, forKey: .publisher)
        developer = try rootContainer.decode(String.self, forKey: .developer)
        releaseDate = try rootContainer.decode(String.self, forKey: .releaseDate)
        profileURL = try rootContainer.decode(String.self, forKey: .profileURL)
        
        if let minSysReqContainer = try? rootContainer.nestedContainer(keyedBy: MinSysReqKeys.self, forKey: .minimumSysReq){
            os = try minSysReqContainer.decode(String.self, forKey: .os)
            processor = try minSysReqContainer.decode(String.self, forKey: .processor)
            memory = try minSysReqContainer.decode(String.self, forKey: .memory)
            graphics = try minSysReqContainer.decode(String.self, forKey: .graphics)
            storage = try minSysReqContainer.decode(String.self, forKey: .storage)
        }
        
        if let screenshotList = try? rootContainer.decode([ScreenshotData].self, forKey: .screenshots){
            for screenshot in screenshotList{
                screenshotID.append(screenshot.id)
                screenshots.append(screenshot.imageLink)
                screenshotImage.append(nil)
                screenshotIsDownloading.append(false)
            }
        }
    }
}

private enum GameKeys: String, CodingKey {
    case id
    case title
    case thumbnail
    case status
    case shortDescription = "short_description"
    case gameURL = "game_url"
    case genre
    case platform
    case publisher
    case developer
    case releaseDate = "release_date"
    case profileURL = "profile_url"
    case minimumSysReq = "minimum_system_requirements"
    case screenshots
}

private enum MinSysReqKeys: String, CodingKey{
    case os
    case processor
    case memory
    case graphics
    case storage
}

//https://stackoverflow.com/questions/55562253/swift-4-decodable-no-value-associated-with-key-codingkeys
private struct ScreenshotData: Decodable {
    var id: Int
    var imageLink: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageLink = "image"
    }
}
