//
//  GameDetailsTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  TableVC for the game details

import UIKit

class GameDetailsTableViewController: UITableViewController, CoreDataListener, FirebaseListener {
    // Static variable
    let SAVED_GAMES_BUTTON = 0
    let WISHLIST_BUTTON = 1
    
    let SECTION_GAME = 0
    let SECTION_SCREENSHOT = 1
    
    let GAME_CELL = "gameDetailsCell"
    let SCREENSHOT_CELL = "screenshotCell"
    
    let NONEXISTENT_DATA = "NaN"

    // Games details
    var theGame: Game?
    var screenshotList: [Screenshot] = []
    var gameID: Int?
    
    // boolean as an indicator between saved games and wishlist
    var insideSavedGame: Bool = false
    var insideWishlist: Bool = false
    
    // Connection with firebase and core data
    var firebaseListenerType: FirebaseListenerType = .all
    weak var firebaseController: FirebaseController?
    
    var coreDataListenerType: CoreDataListenerType = .game
    weak var coreDataController: CoreDataController?
    
    @IBOutlet weak var savedGamesOrWishlistButtonOption: UIBarButtonItemGroup!
    
    // selector function for savedGames / Wishlist Button
    @objc func addSavedGames(_ sender: UIButton) {
        guard let gameID else {
            return
        }
        
        // if this game is part of the savedGame, remove from it
        if insideSavedGame{
            firebaseController?.removeGameFromSavedGames(gameID: gameID)
            addToSavedGamesPrompt(enable: false)
            return
        }
        // otherwise, it is not added yet so just add to the library (firebase)
        let _ = firebaseController?.addGameToSavedGames(gameID: gameID)
        addToSavedGamesPrompt(enable: true)
    }
    
    @objc func addGameToWishlist(_ sender: UIButton) {
        guard let gameID else {
            return
        }
        
        // if this game is part of the wishlist, remove from it
        if insideWishlist{
            firebaseController?.removeGameFromWishlist(gameID: gameID)
            addToWishlistPrompt(enable: false)
            return
        }
        
        // otherwise, it is not added yet so just add to the library (firebase)
        let _ = firebaseController?.addGameToWishlist(gameID: gameID)
        addToWishlistPrompt(enable: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the firebase and coredata connection
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
        
        coreDataController = appDelegate?.coreDataController
        coreDataController?.gameID = gameID
        
        // if the user hasn't logged in, dont show the button
        let user = firebaseController?.currentUser
        if user == nil {
            savedGamesOrWishlistButtonOption.isHidden = true
        }

        // Setup the savedGames / Wishlist button
        let savedGamesOption = UIBarButtonItem(title: "Add to Saved Games", style: .plain, target: self, action: #selector(addSavedGames(_:)))
        let wishlistOption = UIBarButtonItem(title: "Add to Wishlist", style: .plain, target: self, action: #selector(addGameToWishlist(_:)))
        
        savedGamesOrWishlistButtonOption.barButtonItems = [savedGamesOption, wishlistOption]
    }
    
    // MARK: Firebase Listener protocol functions
    func onNewsChange(change: CoreDataChange, news: [NewsAPI]) {
        // Do nothing
    }
    
    func onAuthStateChange(newAuthState: Bool) {
        // Do nothing
    }
    
    func onWishlistChange(change: DatabaseChange, wishlist: [Int]) {
        // whenever we get an update from firebase, update the wishlist
        for eachID in wishlist{
            if eachID == gameID {
                insideWishlist = true
                savedGamesOrWishlistButtonOption.barButtonItems[WISHLIST_BUTTON].title = "Remove from Wishlist"
            }
        }
        print(wishlist)
    }
    
    func onSavedGamesChange(change: DatabaseChange, savedGames: [Int]) {
        // whenever we get an update from firebase, update the savedGames list
        for eachID in savedGames{
            if eachID == gameID {
                insideSavedGame = true
                savedGamesOrWishlistButtonOption.barButtonItems[SAVED_GAMES_BUTTON].title = "Remove from Saved Games"
            }
        }
        print(savedGames)
    }
    
    func onGamesChange(change: CoreDataChange, games: [Game?]) {
        // Do nothing
    }
    
    // MARK: - Function to help CoreDataController protocol
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataController?.addListener(listener: self)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        theGame = nil
        coreDataController?.removeListener(listener: self)
        firebaseController?.removeListener(listener: self)
    }
    
    func onGameChange(change: CoreDataChange, game: Game?) {
        if let game {
            theGame = game;
            tableView.reloadData()
        } else {
            Task(priority: .high) {
                await requestGame()
                tableView.reloadData()
            }
        }
    }
    
    func onScreenshotChange(change: CoreDataChange, screenshot: [Screenshot]) {
        // when we retrieve the game from coredata, we can also get the screenshot (fasten the loading time (a very little time))
        if let _ = theGame {
            var updatedScreenshotList = [Screenshot]()
            
            for each in screenshot {
                if each.screenshotImage != nil {
                    updatedScreenshotList.append(each)
                }
            }
            
            screenshotList = updatedScreenshotList
        }
    }
    
    // MARK: - Function to fetch data from API
    func setUpNoInternetSituation(){
        displayMessage(title: "No Internet Connection", message: "Please check your internet connection, we can't retrieve any data.")
    }
    
    func requestGame() async {
        // request the game from API request
        
        guard let gameID else {
            return
        }
        
        // URL components (links)
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.mmobomb.com"
        searchURLComponents.path = "/api1/game"
        searchURLComponents.queryItems = [
                URLQueryItem(name: "id", value: "\(String(describing: gameID))")
            ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // if we get the data, continue into the decode part
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            
            let gameData = try decoder.decode(GameData.self, from: data)
            
            // save those screenshot into core data, so later we don't have to download it again if we already have the image
            for index in 0..<gameData.screenshotID.count {
                let screenshot = coreDataController?.addScreenshot(id: gameData.screenshotID[index], link: gameData.screenshots[index])
                
                if let screenshot {
                    screenshotList.append(screenshot)
                }
            }
            
            // start downloading the screenshot
            Task {
                await downloadScreenshot()
            }

            theGame = coreDataController?.addGame(gameData)

        } catch {
            // show message (pop up)
            setUpNoInternetSituation()
        }
    }
    
    // download the image if it is not exist yet
    func downloadScreenshot() async {
        for screenshot in screenshotList {
            
            // if the screen doesn't have any image yet
            if screenshot.screenshotImage == nil, screenshot.screenshotIsDownloading == false, let screenshotURL = screenshot.screenshotURL{

                var requestURL: URL?

                requestURL = URL(string: screenshotURL)

                if let requestURL {
                    Task {
                        screenshot.screenshotIsDownloading = true

                        do {
                            let (data, response) = try await URLSession.shared.data(from: requestURL)

                            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                screenshot.screenshotIsDownloading = false
                                throw GameDataError.invalidScreenshotURL
                            }

                            // get the data (downloaded), assign this data for the object that we have
                            // so that we don't have to download it again when we load this screen
                            if let _ = UIImage(data: data) {
                                screenshot.screenshotImage = data
                                tableView.reloadData()
                                await MainActor.run{
                                    tableView.reloadData()
                                }
                            } else {
                                screenshot.screenshotIsDownloading = false
                            }
                        } catch {
                            print(error.localizedDescription)
                        }

                        screenshot.screenshotIsDownloading = false
                    }
                } else {
                    //print("Error: URL not valid: " + imageURL)
                }
                screenshot.screenshotIsDownloading = false
            }
        }
    }
    
    // MARK: update the UI State for adding/removing games from wishlist / savedgames Option
    func addToWishlistPrompt(enable: Bool){
        insideWishlist = enable
        if enable{
            savedGamesOrWishlistButtonOption.barButtonItems[WISHLIST_BUTTON].title = "Remove from Wishlist"
            return
        }
        savedGamesOrWishlistButtonOption.barButtonItems[WISHLIST_BUTTON].title = "Add to Wishlist"
    }
    
    func addToSavedGamesPrompt(enable: Bool){
        insideSavedGame = enable
        if enable{
            savedGamesOrWishlistButtonOption.barButtonItems[SAVED_GAMES_BUTTON].title = "Remove from Saved Games"
            return
        }
        savedGamesOrWishlistButtonOption.barButtonItems[SAVED_GAMES_BUTTON].title = "Add to Saved Games"
        return
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case SECTION_GAME:
            return 1
        case SECTION_SCREENSHOT:
            return screenshotList.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
        if indexPath.section == SECTION_GAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: GAME_CELL, for: indexPath) as! GameDetailsTableViewCell

            // Configure the cell...
            guard let theGame else{
                return cell
            }
            
            // Deal with the image, by downloading from the website again.
            cell.thumbnailView.image = nil
            
            theGame.thumbnailIsDownloading = false
            
            //check the thumbnail image first whether its already fetched before or not.
            if let image = theGame.thumbnailImage {
                cell.thumbnailView.image = UIImage(data: image)
            } else if theGame.thumbnailIsDownloading == false, let thumbnailURL = theGame.thumbnail{
                //try to fetch the data
                let requestURL = URL(string: thumbnailURL)
                
                if let requestURL {
                    Task(priority: .userInitiated){
                        theGame.thumbnailIsDownloading = true
                        
                        do {
                            // get the response
                            let (data, response) = try await URLSession.shared.data(from: requestURL)
                            
                            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                theGame.thumbnailIsDownloading = false
                                throw GamesDataError.invalidThumbnailURL
                            }
                            // get the data (downloaded), assign this data for the object that we have
                            // so that we don't have to download it again when we load this screen
                            if let image = UIImage(data: data) {
                                print("Image downloaded: " + thumbnailURL)
                                theGame.thumbnailImage = image.pngData()
                                cell.thumbnailView.image = image
                                await MainActor.run{
                                    tableView.reloadData()
                                }
                            } else {
                                print("Image invalid: " + thumbnailURL)
                                theGame.thumbnailIsDownloading = false
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        theGame.thumbnailIsDownloading = false
                    }
                } else {
                    //print("Error: URL not valid: " + imageURL)
                }
            }
            
            // set up the cell information text
            cell.titleLabel.text = theGame.title
            cell.statusLabel.text = "Status: " + theGame.status!
            cell.descriptionLabel.text = theGame.shortDesc
            cell.genreLabel.text = "Genre: " + theGame.genre!
            cell.platformLabel.text = "Platform: " + theGame.platform!
            cell.publisherLabel.text = "Publisher: " + theGame.publisher!
            cell.developerLabel.text = "Developer: " + theGame.developer!
            cell.releaseDateLabel.text = "Release Date: " + theGame.releaseDate!
            cell.websiteLinkLabel.text = "Game Website: " + theGame.gameURL!
            
            cell.osLabel.text = "OS: " + (theGame.os ?? NONEXISTENT_DATA)
            cell.processorLabel.text = "Processor: " + (theGame.processor ?? NONEXISTENT_DATA)
            cell.memoryLabel.text = "Memory: " + (theGame.memory ?? NONEXISTENT_DATA)
            cell.graphicsLabel.text = "Graphics: " + (theGame.graphics ?? NONEXISTENT_DATA)
            cell.storageLabel.text = "Storage: " + (theGame.storage ?? NONEXISTENT_DATA)

            return cell
        } else {
            // this cell is related to the screenshot.
            let cell = tableView.dequeueReusableCell(withIdentifier: SCREENSHOT_CELL, for: indexPath) as! GameScreenshotTableViewCell
            
            if let image = screenshotList[indexPath.row].screenshotImage {
                cell.screenshotView.image = UIImage(data: image)
            }
            
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
