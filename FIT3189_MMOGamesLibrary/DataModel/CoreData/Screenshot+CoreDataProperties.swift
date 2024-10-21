//
//  Screenshot+CoreDataProperties.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 10/5/2023.
//
//  Screenshot properties in Core Data

import Foundation
import CoreData


extension Screenshot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Screenshot> {
        return NSFetchRequest<Screenshot>(entityName: "Screenshot")
    }

    @NSManaged public var gameID: Int32
    @NSManaged public var screenshotID: Int32
    @NSManaged public var screenshotImage: Data?
    @NSManaged public var screenshotIsDownloading: Bool
    @NSManaged public var screenshotShown: Bool
    @NSManaged public var screenshotURL: String?

}

extension Screenshot : Identifiable {

}
