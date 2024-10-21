//
//  CoreDataProtocol.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 9/5/2023.
//  Core data protocol, deal with all related connection like adding, removing, data from core data

import Foundation

enum CoreDataChange {
    case add        // add data to core data
    case remove     // remove data from core data
    case update     // update the existed data in the core data
}

enum CoreDataListenerType {
    case game       // VC will retrieve one game only
    case games      // VC will retrieve multiple games
    case news       // VC will retrieve multiple news
}

protocol CoreDataListener: AnyObject{
    // 'marker' for each VC who want to get a related data (based on the CoreDataListenerType)
    var coreDataListenerType: CoreDataListenerType {get set}
    
    func onGameChange(change: CoreDataChange, game: Game?)                      // update the game to the related VC
    func onGamesChange(change: CoreDataChange, games: [Game?])                  // update the games to the related VC (wishlist and saved games)
    func onScreenshotChange(change: CoreDataChange, screenshot: [Screenshot])   // Update screenshot to the related VC (Game Details VC)
    func onNewsChange(change: CoreDataChange, news: [NewsAPI])                  // update news to the related VC
}

protocol CoreDataProtocol: AnyObject{
    func cleanup()          // save all the updated object in the core data
    func newsCleanup()      // remove all the old news object in the core data, and replace it with the new one
    
    func addListener(listener: CoreDataListener)        // add listener to the related VC so they can retrieve the related data
    func removeListener(listener: CoreDataListener)     // remove it
    
    func fetchGames() -> [Game?]                // fetch the games from core data (Saved games and wishlist)
    func fetchGame() -> Game?                   // fetch a game from core data
    func fetchScreenshot() -> [Screenshot]      // fetch the screenshot (game details)
    
    func fetchNews() -> [NewsAPI]               // fetch news for the dashboard
    
    func addGame(_ game: GameData) -> Game                      // add game to the coredata
    func addScreenshot(id: Int, link: String) -> Screenshot     // add screenshot to the coredata
    func addNews(_ news: NewsData) -> NewsAPI                   // add news to the coredata
}
