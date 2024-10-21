//
//  GamesLibraryTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 18/4/2023.
//  VC for showing all games that we get from API

import UIKit

class GamesLibraryTableViewController: UITableViewController, UISearchBarDelegate {
    //outlet segmented control
    @IBOutlet weak var searchOption: UISegmentedControl!
    
    @IBOutlet weak var settingOptionsButton: UIBarButtonItem!
    
    var sortOption: String = "popularity"
    
    // static variable
    let GAME_CELL = "gameCell"
    let GAME_SECTION = 0
    
    let INFO_CELL = "infoCell"
    let INFO_SECTION = 1
    
    var gamesList = [GamesData]()
    var backupGamesList = [GamesData]()
    
    // search failed (no internet connection boolean)
    var searchFailed = false;
    
    // indicator screen
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // function for 'sort by' search
        let updateLibrary = {(action: UIAction) in
            self.sortOption = action.title.lowercased().replacingOccurrences(of: " ", with: "-")
            
            self.gamesList.removeAll()
            self.tableView.reloadData()
            self.indicator.startAnimating()
            
            Task {
                await self.requestGames()
            }
        }
        
        // insert the menu for the button
        settingOptionsButton.menu = UIMenu(children: [
            UIAction(title: "Popularity", state: .on, handler: updateLibrary),
            UIAction(title: "Alphabetical", state: .on, handler: updateLibrary),
            UIAction(title: "Release Date", state: .on, handler: updateLibrary),
            UIAction(title: "Relevance", state: .on, handler: updateLibrary),
        ])
        
        settingOptionsButton.changesSelectionAsPrimaryAction = true
        
        //Setup the search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        
        // Ensure the search bar is hidden when scrolling
        navigationItem.hidesSearchBarWhenScrolling = false

        //setup the indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        indicator.startAnimating()
        
        // Fetching data from API
        Task(priority: .background) {
            await requestGames()
            print("Done")
        }
    }

    // MARK: - Function from UISearchBarDelegate
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        backupGamesList = gamesList
        gamesList.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text?.lowercased() else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        URLSession.shared.invalidateAndCancel()
        
        let selectedSearchOption = searchOption.titleForSegment(at: searchOption.selectedSegmentIndex)
        
        switch selectedSearchOption{
        case "Name":
            searchGamesBy(name: searchText)
        case "Tag":
            Task{
                await requestGamesBy(tag: searchText)
            }
        default:
            print("")
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // assign the backup list, so in case we cancel the search, it will show the old game list that we have
        backupGamesList = gamesList
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // assign back to the original list that we had before
        gamesList = backupGamesList
        tableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // MARK: - Function to help find a particular game
    func searchGamesBy(name: String) {
        // search by name manually by iterate through each object
        var foundGame = [GamesData]()
        for game in backupGamesList{
            if let title = game.title {
                if title.lowercased().contains("\(name)") {
                    foundGame.append(game)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
        
        gamesList = foundGame
        tableView.reloadData()
    }

    // MARK: - Function to fetch data from API
    // if there is no internet connection, show the corresponding message (table view cell)
    func setUpNoInternetSituation(){
        indicator.stopAnimating()
        searchFailed = true
        tableView.reloadData()
        
        //reset the value
        searchFailed = false
    }
    
    // request game through the API request based on the TAG
    func requestGamesBy(tag: String) async{
        // URL components (links)
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.mmobomb.com"
        searchURLComponents.path = "/api1/filter"
        
        let tagList = tag.components(separatedBy: " ")
        let tag = tagList.joined(separator: ".")
        
        searchURLComponents.queryItems = [
            URLQueryItem(name: "tag", value: tag),
            URLQueryItem(name: "sort-by", value: sortOption)
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // try to fetch the URL
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            // get the data, try to decode it
            let decoder = JSONDecoder()
            let gamesData = try decoder.decode([GamesData].self, from: data)
            
            let pointerStart = gamesList.count
            
            // once we retrieve the data, saved it inside this VC games list
            for game in gamesData{
                gamesList.append(game)
                
                let pointerEnd = gamesList.count
                
                var indexPaths = [IndexPath()]
                
                for row in pointerStart...pointerEnd {
                    indexPaths.append(IndexPath(row: row, section: 0))
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        } catch {
            self.setUpNoInternetSituation()
        }
        
    }
    
    // request game through the API request based on the NAME
    func requestGames() async {
        // URL components (links)
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.mmobomb.com"
        searchURLComponents.path = "/api1/games"
        
        searchURLComponents.queryItems = [
            URLQueryItem(name: "sort-by", value: sortOption)
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // try to fetch the URL
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            // get the data, try to decode it
            let decoder = JSONDecoder()
            let gamesData = try decoder.decode([GamesData].self, from: data)
            
            let pointerStart = gamesList.count
            
            // once we retrieve the data, saved it inside this VC games list
            for game in gamesData{
                gamesList.append(game)
                
                let pointerEnd = gamesList.count
                
                var indexPaths = [IndexPath()]
                
                for row in pointerStart...pointerEnd {
                    indexPaths.append(IndexPath(row: row, section: 0))
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            backupGamesList = gamesList
            
        } catch {
            self.setUpNoInternetSituation()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case GAME_SECTION:
            return gamesList.count
        case INFO_SECTION:
            if searchFailed == true{
                return 1
            }
            return 0
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == GAME_SECTION {
            let gameCell = tableView.dequeueReusableCell(withIdentifier: GAME_CELL, for: indexPath) as! GameTableViewCell

            // Configure the cell...
            let game = gamesList[indexPath.row]
            gameCell.titleLabel.text = game.title
            gameCell.genreLabel.text = game.genre
            gameCell.releaseDateLabel.text = game.releaseDate
            
            // Deal with the image, by downloading from the website again.
            gameCell.thumbnailImage.image = nil
            
            game.thumbnailIsDownloading = false
            
            //check the thumbnail image first whether its already fetched before or not.
            if let image = game.thumbnailImage {
                gameCell.thumbnailImage.image = image
            } else if game.thumbnailIsDownloading == false, let thumbnailURL = game.thumbnail{
                
                //try to fetch the data
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
                                game.thumbnailImage = image
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
            
            return gameCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL, for: indexPath) as! NoInternetTableViewCell
            cell.messageLabel.text = "Sorry, There is an error, try again next time. Check your internet connection."
            
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // indicate which cell that user choose
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        // set the segue for showing the game details
        if segue.identifier == "gameDetailsSegue"{
            let destination = segue.destination as! GameDetailsTableViewController
            
            // pass on the game
            let game = gamesList[indexPath.row]
            destination.gameID = game.id
        }
    }
}
