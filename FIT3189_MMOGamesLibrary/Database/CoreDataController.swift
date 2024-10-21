//
//  CoreDataController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 9/5/2023.
//  Coredata controller, deal with all things that are related with the persistent storage
//  Adding, deleting, updating the existed data or even new data.

import UIKit
import CoreData

class CoreDataController: NSObject, CoreDataProtocol, NSFetchedResultsControllerDelegate{
    var listeners = MulticastDelegate<CoreDataListener>()
    // connection to core data
    var persistentContainer: NSPersistentContainer
    
    // fetch variable for each 'data' that we want to get
    var gameFetchedResultsController: NSFetchedResultsController<Game>?
    var screenshotsFetchedResultsController: NSFetchedResultsController<Screenshot>?
    var newsFetchedResultsController: NSFetchedResultsController<NewsAPI>?
    
    // variables for the related games
    var theGame: Game?
    var gamesID: [Int] = []
    var gameID: Int?
    
    override init(){
        // set up the conenction to the core data
        persistentContainer = NSPersistentContainer(name: "GameDataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error {
                fatalError("Failed to load Core Data Stack with error : \(String(describing: error))")
            }
        }
        
        super.init()
    }
    
    // MARK: Delete old news
    // this cleanup will be executed if the user close the app
    // this how it works, the news that user load in the current session will be saved once the user close the app
    // if in the next run, user open the app again, they might get a new data from API
    // so just delete the entire old news and replace it with the new one.
    func newsCleanup(){
        // try to fetch the existed object
        if newsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<NewsAPI> = NewsAPI.fetchRequest()
            let noneSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [noneSortDescriptor]
            
            
            newsFetchedResultsController = NSFetchedResultsController<NewsAPI>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            newsFetchedResultsController?.delegate = self
            
            // fetch it
            do {
                try newsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(String(describing: error))")
            }
            
            // delete it
            if let result = newsFetchedResultsController?.fetchedObjects{
                let fetch: NSFetchRequest<NSFetchRequestResult> = NewsAPI.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                for each in result {
                    persistentContainer.viewContext.delete(each as NSManagedObject)
                }
            }
        }
        newsFetchedResultsController = nil
    }
    
    // MARK: Functions from CoreDataProtocol
    func cleanup() {        
        // then save for all changed object in core data
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(String(describing: error))")
            }
        }
    }
    
    // add the listener to the corresponding VC so they can retrieve the related data that they need
    func addListener(listener: CoreDataListener) {
        listeners.addDelegate(listener)
        
        if listener.coreDataListenerType == .game {
            listener.onGameChange(change: .update, game: fetchGame())
            listener.onScreenshotChange(change: .update, screenshot: fetchScreenshot())
        }
        if listener.coreDataListenerType == .games {
            listener.onGamesChange(change: .update, games: fetchGames())
        }
        if listener.coreDataListenerType == .news {
            listener.onNewsChange(change: .update, news: fetchNews())
        }
    }
    
    // remove the listener from the corresponding VC
    func removeListener(listener: CoreDataListener) {
        listeners.removeDelegate(listener)
    }
    
    // fetch the games from core data if we already have it
    func fetchGames() -> [Game?] {
        var fetchedGames: [Game?] = []
        for gameID in gamesID {
            
            // fetch it
            if gameFetchedResultsController == nil {
                let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
                let idSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
                
                var predicate: NSPredicate?
                
                predicate = NSPredicate(format: "id == %@", String(gameID))
                
                fetchRequest.sortDescriptors = [idSortDescriptor]
                fetchRequest.predicate = predicate
                
                gameFetchedResultsController = NSFetchedResultsController<Game>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                
                gameFetchedResultsController?.delegate = self
                
                // get the data
                do {
                    try gameFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch request failed: \(String(describing: error))")
                }
            }
            
            // get the first one if we have multiple games
            var fetchedGame: Game?
            if gameFetchedResultsController?.fetchedObjects != nil {
                fetchedGame = gameFetchedResultsController?.fetchedObjects?.first
            }
            
            gameFetchedResultsController = nil
            
            if let fetchedGame {
                fetchedGames.append(fetchedGame)
            } else {
                fetchedGames.append(nil)
            }
        }
        return fetchedGames
    }
    
    // fetch one games based on the ID that have been assigned into this coredatacontroller
    func fetchGame() -> Game?  {
        if gameFetchedResultsController == nil {
            // setup the fetch
            let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
            let idSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            
            var predicate: NSPredicate?
            
            if let gameID  {
                predicate = NSPredicate(format: "id == %@", String(gameID))
            }
            
            fetchRequest.sortDescriptors = [idSortDescriptor]
            fetchRequest.predicate = predicate
            
            gameFetchedResultsController = NSFetchedResultsController<Game>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            gameFetchedResultsController?.delegate = self
            
            // fetch
            do {
                try gameFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(String(describing: error))")
            }
        }
        
        // get the first object in case we have multiple games
        var fetchedGame: Game?
        if gameFetchedResultsController?.fetchedObjects != nil {
            fetchedGame = gameFetchedResultsController?.fetchedObjects?.first
        }
        
        gameFetchedResultsController = nil
        
        if let fetchedGame {
            return fetchedGame
        }
        return nil
    }
    
    // fetch the screenshot
    func fetchScreenshot() -> [Screenshot] {
        if screenshotsFetchedResultsController == nil {
            // setup the screenshot
            let fetchRequest: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
            let idSortDescriptor = NSSortDescriptor(key: "gameID", ascending: true)
            
            var predicate: NSPredicate?
            
            if let gameID {
                predicate = NSPredicate(format: "gameID == %@", String(gameID))
            }
            
            fetchRequest.sortDescriptors = [idSortDescriptor]
            fetchRequest.predicate = predicate
            
            screenshotsFetchedResultsController = NSFetchedResultsController<Screenshot>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            screenshotsFetchedResultsController?.delegate = self
            
            // fetch the data
            do {
                try screenshotsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(String(describing: error))")
            }
        }
        
        var fetchedScreenshot = [Screenshot]()
        if let result = screenshotsFetchedResultsController?.fetchedObjects{
            fetchedScreenshot = result
        }
        
        screenshotsFetchedResultsController = nil
        
        return fetchedScreenshot
    }
    
    // fetch the news from core data
    func fetchNews() -> [NewsAPI] {
        if newsFetchedResultsController == nil {
            // setup the fetching moment
            let fetchRequest: NSFetchRequest<NewsAPI> = NewsAPI.fetchRequest()
            let noneSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [noneSortDescriptor]
            
            
            newsFetchedResultsController = NSFetchedResultsController<NewsAPI>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            newsFetchedResultsController?.delegate = self
            
            // fetch the data
            do {
                try newsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(String(describing: error))")
            }
        }
        
        var fetchedNews = [NewsAPI]()
        if let result = newsFetchedResultsController?.fetchedObjects{
            fetchedNews = result
        }
        
        newsFetchedResultsController = nil
        
        return fetchedNews
    }

    func addGame(_ game: GameData) -> Game {
        // add the game into the core data
        let newGame = NSEntityDescription.insertNewObject(forEntityName: "Game", into: persistentContainer.viewContext) as! Game
        
        // assign the related attribute for the object.
        if let id = game.id {
            newGame.id = Int32(id)
        }
        newGame.title = game.title
        newGame.status = game.status
        newGame.shortDesc = game.shortDescription
        newGame.gameURL = game.gameURL
        newGame.genre = game.genre
        newGame.platform = game.platform
        newGame.publisher = game.publisher
        newGame.developer = game.developer
        newGame.releaseDate = game.releaseDate
        newGame.profileURL = game.profileURL
        newGame.os = game.os
        newGame.processor = game.processor
        newGame.memory = game.memory
        newGame.graphics = game.graphics
        newGame.storage = game.storage
        newGame.thumbnail = game.thumbnail
        
        if let img = game.thumbnailImage {
            newGame.thumbnailImage = img.pngData()
        }
        newGame.thumbnailIsDownloading = game.thumbnailIsDownloading
        newGame.thumbnailShown = game.thumbnailShown
        return newGame
    }
    
    func addScreenshot(id: Int, link: String) -> Screenshot {
        // check first whether we already download it or not
        let savedScreenshot = self.fetchScreenshot()
        let exist = savedScreenshot.contains(where: { $0.screenshotID == id })
        
        // if it exist, just return it
        if exist, let screenshot = savedScreenshot.first(where: { $0.screenshotID == id }){
            print("NOT ADDED INTO CORE DATA, IT IS ALREADY EXIST")
            return screenshot
        }
        
        // otherwise
        // add the screenshot into the core data
        let newScreenshot = NSEntityDescription.insertNewObject(forEntityName: "Screenshot", into: persistentContainer.viewContext) as! Screenshot
        
        // assign the related attribute to the object
        newScreenshot.screenshotID = Int32(id)
        if let gameID {
            newScreenshot.gameID = Int32(gameID)
        }
        newScreenshot.screenshotURL = link
        newScreenshot.screenshotIsDownloading = false
        newScreenshot.screenshotShown = true
        newScreenshot.screenshotImage = nil
        
        cleanup()
        
        return newScreenshot

    }
    
    func addNews(_ news: NewsData) -> NewsAPI {
        // add the game into the core data
        let newNews = NSEntityDescription.insertNewObject(forEntityName: "NewsAPI", into: persistentContainer.viewContext) as! NewsAPI
        
        // assign the attribute
        if let id = news.id {
            newNews.id = Int32(id)
        }
        newNews.articleContent = news.articleContent
        newNews.shortDesc = news.shortDescription
        newNews.thumbnailURL = news.thumbnail
        newNews.title = news.title
        
        if let image = news.thumbnailImage {
            newNews.thumbnailImage = image.pngData()
        }
        newNews.thumbnailShown = true
        newNews.thumbnailIsDownloading = false
        
        cleanup()

        return newNews
    }
}
