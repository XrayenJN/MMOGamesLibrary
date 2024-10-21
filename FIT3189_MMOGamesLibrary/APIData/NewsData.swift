//
//  NewsData.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  News object that we get from API

import UIKit

// Enum error if we can't reach the URL
enum NewsDataError: Error {
    case invalidThumbnailURL
}

// News object
class NewsData: NSObject, Decodable {
    var id: Int?
    var title: String?
    var shortDescription: String?
    var thumbnail: String?
    var mainImage: String?
    var articleContent: String?
    var articleURL: String?
    
    // used for downloading thumbnail
    var thumbnailImage: UIImage?
    var thumbnailIsDownloading: Bool = false
    var thumbnailShown: Bool = true
    
    // Break down the information that we get from API
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: NewsKeys.self)
        
        id = try rootContainer.decode(Int.self, forKey: .id)
        title = try rootContainer.decode(String.self, forKey: .title)
        shortDescription = try rootContainer.decode(String.self, forKey: .shortDescription)
        thumbnail = try rootContainer.decode(String.self, forKey: .thumbnail)
        mainImage = try rootContainer.decode(String.self, forKey: .mainImage)
        articleContent = try rootContainer.decode(String.self, forKey: .articleContent)
        articleURL = try rootContainer.decode(String.self, forKey: .articleURL)
    }
}

private enum NewsKeys: String, CodingKey{
    case id
    case title
    case shortDescription = "short_description"
    case thumbnail
    case mainImage = "main_image"
    case articleContent = "article_content"
    case articleURL = "article_url"
}
