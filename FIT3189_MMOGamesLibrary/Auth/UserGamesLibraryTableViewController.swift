//
//  UserGamesLibraryTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 15/5/2023.
//  VC for showing the user game library
//  there are two kinds of library each user has
//  First one is the wishlist
//  Second one is the saved games

//  User can also delete the object by swipe left

import UIKit

class UserGamesLibraryTableViewController: UITableViewController, FirebaseListener, CoreDataListener {
    // Static variable
    let WISHLIST_IDENTITY = "Wishlist"
    let SAVED_GAMES_IDENTITY = "Saved Games"
    let GAME_CELL = "gameCell"
    
    var identity: String?
    // the id games that we get from firebase
    var gamesIDList = [Int]()
    // the game data itself based on the ID that we have (above)
    var gamesList = [Game?]()
    
    var firebaseListenerType: FirebaseListenerType = .savedGames
    weak var firebaseController: FirebaseController?
    
    var coreDataListenerType: CoreDataListenerType = .games
    weak var coreDataController: CoreDataController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the firebase / coredata controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
        coreDataController = appDelegate?.coreDataController
        
        // set the library to check which one should be retrieved from the firebase
        // saved games / wishlist data
        self.setLibrary()
    }
    // MARK: - Protocol functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
        coreDataController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coreDataController?.removeListener(listener: self)
        firebaseController?.removeListener(listener: self)
    }
    
    // MARK: - Function from database protocol
    func onGamesChange(change: CoreDataChange, games: [Game?]) {
        gamesList = games
        tableView.reloadData()
        
        // if we get nothing from the core data, fetch if from API
        for index in 0..<gamesList.count {
            if gamesList[index] == nil {
                Task {
                    await fetchGameUsingGameID(index)
                }
            }
        }
        tableView.reloadData()
    }
    
    func onAuthStateChange(newAuthState: Bool) {
        // Do nothing
    }
    
    func onWishlistChange(change: DatabaseChange, wishlist: [Int]) {
        // Change the wishlist
        gamesIDList = wishlist
        coreDataController?.gamesID = wishlist
        tableView.reloadData()
    }
    
    func onSavedGamesChange(change: DatabaseChange, savedGames: [Int]) {
        // Change the saved Games list
        gamesIDList = savedGames
        coreDataController?.gamesID = savedGames
        tableView.reloadData()
    }
    
    func onGameChange(change: CoreDataChange, game: Game?) {
        // Do nothing
    }
    
    func onScreenshotChange(change: CoreDataChange, screenshot: [Screenshot]) {
        // Do nothing
    }
    
    func onNewsChange(change: CoreDataChange, news: [NewsAPI]) {
        // do nothing
    }
    
    // MARK: - Fetch game from API
    func fetchGameUsingGameID(_ index: Int) async{
        // URL components (links)
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.mmobomb.com"
        searchURLComponents.path = "/api1/game"
        searchURLComponents.queryItems = [
                URLQueryItem(name: "id", value: "\(String(describing: gamesIDList[index]))")
            ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // get the data
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            
            // decode the data based on the GameData that we have
            let gameData = try decoder.decode(GameData.self, from: data)
            
            // add the screenshot to core data
            for index in 0..<gameData.screenshotID.count {
                let screenshot = coreDataController?.addScreenshot(id: gameData.screenshotID[index], link: gameData.screenshots[index])
            }
            
            // add the game to the core data
            let game = coreDataController?.addGame(gameData)
            gamesList[index] = game
            tableView.reloadData()

        } catch let error {
            print(error)
        }
    }
    
    // MARK: - Additional function to help determine whether it is a savedGames library or wishlist library
    func setLibrary(){
        if identity == WISHLIST_IDENTITY {
            self.title = WISHLIST_IDENTITY
            self.firebaseListenerType = .wishlist
            return
        }
        self.title = SAVED_GAMES_IDENTITY
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gamesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gameCell = tableView.dequeueReusableCell(withIdentifier: GAME_CELL, for: indexPath) as! GameTableViewCell
        
        let game = gamesList[indexPath.row]
        if let game{
            gameCell.titleLabel.text = game.title
            gameCell.genreLabel.text = game.genre
            gameCell.releaseDateLabel.text = game.releaseDate
            
            // Deal with the image, by downloading from the website again.
            gameCell.thumbnailImage.image = nil
            
            game.thumbnailIsDownloading = false
            
            //check the thumbnail image first whether its already fetched before or not.
            if let image = game.thumbnailImage {
                gameCell.thumbnailImage.image = UIImage(data: image)
            } else if game.thumbnailIsDownloading == false, let thumbnailURL = game.thumbnail{
                
                //try to download the image
                let requestURL = URL(string: thumbnailURL)
                
                if let requestURL {
                    Task{
                        game.thumbnailIsDownloading = true
                        
                        do {
                            // get the response
                            let (data, response) = try await URLSession.shared.data(from: requestURL)
                            
                            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                game.thumbnailIsDownloading = false
                                throw GamesDataError.invalidThumbnailURL
                            }
                            // get the data (downloaded), assign this data for the object that we have
                            // so that we don't have to download it again when we load this screen
                            if let image = UIImage(data: data) {
                                print("Image downloaded: " + thumbnailURL)
                                game.thumbnailImage = image.pngData()
                                gameCell.thumbnailImage.image = image
                                await MainActor.run{
                                    tableView.reloadData()
                                }
                            } else {
                                print("Image invalid: " + thumbnailURL)
                                game.thumbnailIsDownloading = false
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        game.thumbnailIsDownloading = false
                    }
                } else {
                    //print("Error: URL not valid: " + imageURL)
                }
            }
        }
        
        return gameCell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.performBatchUpdates({
                let deletedGameID = gamesIDList.remove(at: indexPath.row)
                gamesList.remove(at: indexPath.row)
                
                //if this VC refers the wishlist game, delete from wishlist folder in firebase
                if identity == WISHLIST_IDENTITY{
                    firebaseController?.removeGameFromWishlist(gameID: deletedGameID)
                } else {
                    // otherwise, just delete from saved games folder
                    firebaseController?.removeGameFromSavedGames(gameID: deletedGameID)
                }

                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([indexPath.section], with: .automatic)

            }, completion: nil)
        }
    }
        
        
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
        
        
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // indicate which cell that user choose
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        // when we want to go to game details, assign the game to the corresponding VC so it can shows the related stuff.
        if segue.identifier == "gameDetailsSegue"{
            let destination = segue.destination as! GameDetailsTableViewController
            
            let game = gamesList[indexPath.row]
            if let game {
                destination.theGame = game
                destination.gameID = Int(game.id)
            }
        }
    }
}
