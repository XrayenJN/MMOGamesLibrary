//
//  DashboardTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 18/4/2023.
//  Dashboard / News Table VC
//  Showing all the news that we get from API request

import UIKit

class DashboardTableViewController: UITableViewController, CoreDataListener {
    // static variable
    let NEWS_CELL = "newsCell"
    let REQUEST_STRING = "https://www.mmobomb.com/api1/latestnews"
    let currentRequestIndex: Int = 0
    
    var newsList = [NewsAPI]()
    // showing loading screen
    var indicator = UIActivityIndicatorView()
    
    // to retrieve the news from core data
    var coreDataListenerType: CoreDataListenerType = .news
    weak var coreDataController: CoreDataController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the core data
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDataController = appDelegate?.coreDataController

        // setup the indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        // activation of the indicator
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        indicator.startAnimating()
        
        // fetch the news from API
        Task {
            await requestNews()
            print("Done")
        }
    }
    
    @IBAction func unwindToDashboardViewController(segue: UIStoryboardSegue) {
        // Just go back to this VC
    }
    
    // MARK: - Function from core data listener
    func onGameChange(change: CoreDataChange, game: Game?) {
        // Do nothing
    }
    
    func onGamesChange(change: CoreDataChange, games: [Game?]) {
        // Do nothing
    }
    
    func onScreenshotChange(change: CoreDataChange, screenshot: [Screenshot]) {
        // Do nothing
    }
    
    func onNewsChange(change: CoreDataChange, news: [NewsAPI]) {
        if newsList.isEmpty{
            newsList = news
        }
        
        tableView.reloadData()
    }

    // MARK: Function to help retrieving data from core data once this VC is loaded
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coreDataController?.removeListener(listener: self)
    }

    
    // MARK: - Function to fetch data from API
    func requestNews() async {
        // URL Component
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.mmobomb.com"
        searchURLComponents.path = "/api1/latestnews"
        
        // Check whether its valid or not
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        //start fetching the data
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            //decode JSON that I got from API
            let decoder = JSONDecoder()
            let newsData = try decoder.decode([NewsData].self, from: data)
            
            
            // store it inside this VC variable
            // reset the newslist (replaced it with what we get from API)
            newsList = [NewsAPI]()
            let pointerStart = newsList.count
            for news in newsData{
                let coreDataNews = coreDataController?.addNews(news)
                
                if let coreDataNews {
                    newsList.append(coreDataNews)
                }

                let pointerEnd = newsList.count
                
                var indexPaths = [IndexPath()]
                
                for row in pointerStart..<pointerEnd {
                    indexPaths.append(IndexPath(row: row, section: 0))
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        } catch {
            displayMessage(title: "No Internet Connection", message: "Please check again your internet connection.")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: NEWS_CELL, for: indexPath) as! NewsTableViewCell
        
        // Configure the cell
        let news = newsList[indexPath.row]
        newsCell.titleLabel.text = news.title
        newsCell.shortDescriptionLabel.text = news.shortDesc
        
        // Dealing with the image
        newsCell.thumbnailView.image = nil
        news.thumbnailIsDownloading = false
        
        // Check the thumbnail image
        if let data = news.thumbnailImage {
            newsCell.thumbnailView.image = UIImage(data: data)
        } else if news.thumbnailIsDownloading == false, let thumbnailURL = news.thumbnailURL {
            // try to download it from the URL that we have before
            let requestURL = URL(string: thumbnailURL)
            
            if let requestURL {
                Task {
                    // async task
                    news.thumbnailIsDownloading = true
                    
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        
                        // once we get the response, we download it
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            news.thumbnailIsDownloading = false
                            throw NewsDataError.invalidThumbnailURL
                        }
                        
                        //fetch the data
                        if let image = UIImage(data: data) {
                            print("Image downloaded: " + thumbnailURL)
                            news.thumbnailImage = data
                            newsCell.thumbnailView.image = image
                            await MainActor.run{
                                tableView.reloadData()
                            }
                        } else {
                            print("Image invalid: " + thumbnailURL)
                            news.thumbnailIsDownloading = false
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    news.thumbnailIsDownloading = false
                }
            } else {
                //print("Error: URL not valid: " + imageURL)
            }
        }
        return newsCell
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
        
        // chose which cell that is picked by the user
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        // do the segue for news detail
        if segue.identifier == "newsDetailSegue" {
            let destination = segue.destination as! NewsDetailTableViewController
            
            let news = newsList[indexPath.row]
            destination.news = news
        }
    }
    

}
