//
//  Game+CoreDataProperties.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 10/5/2023.
//
//  Properties of the Game object in core data

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var developer: String?
    @NSManaged public var gameURL: String?
    @NSManaged public var genre: String?
    @NSManaged public var graphics: String?
    @NSManaged public var id: Int32
    @NSManaged public var memory: String?
    @NSManaged public var os: String?
    @NSManaged public var platform: String?
    @NSManaged public var processor: String?
    @NSManaged public var profileURL: String?
    @NSManaged public var publisher: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var status: String?
    @NSManaged public var storage: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var thumbnailImage: Data?
    @NSManaged public var thumbnailIsDownloading: Bool
    @NSManaged public var thumbnailShown: Bool
    @NSManaged public var title: String?

}

extension Game : Identifiable {

}
