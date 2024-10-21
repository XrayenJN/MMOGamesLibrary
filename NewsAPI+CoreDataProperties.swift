//
//  NewsAPI+CoreDataProperties.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 9/6/2023.
//
//

import Foundation
import CoreData


extension NewsAPI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsAPI> {
        return NSFetchRequest<NewsAPI>(entityName: "NewsAPI")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var thumbnailImage: Data?
    @NSManaged public var articleContent: String?
    @NSManaged public var thumbnailIsDownloading: Bool
    @NSManaged public var thumbnailShown: Bool

}

extension NewsAPI : Identifiable {

}
