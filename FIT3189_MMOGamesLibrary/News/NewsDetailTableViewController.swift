//
//  NewsDetailTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 23/4/2023.
//  News Details VC, showing all the news detail information
//  there are / are not videos in the news that we get from API
//  so this VC will show any videos if there is any video that we get
//      when we decode the article content

import UIKit
import WebKit

class NewsDetailTableViewController: UITableViewController {
    
    let NEWS_CELL = "newsDetailsCell"
    let VIDEO_CELL = "videoCell"
    
    let NEWS_SECTION = 0
    let VIDEO_SECTION = 1
    
    var news: NewsAPI?
    var videoURLs: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.setUpIframe()
    }
    
    // MARK: Setup the Video Iframe if it is available
    func setUpIframe(){
        guard let news, let articleContent = news.articleContent else {
            return
        }
        // Configure the cell...
        var htmlString = ""
        
        if articleContent.contains("&gt;"){
            htmlString = articleContent.decoded
        } else {
            htmlString = articleContent.removeTags
        }
        
        //        Prompt for chatgpt
        //        I have text
        //        this text has several or even none of <iframe ...> </iframe>
        //
        //        I want to store the information of that iframe in my list
        //
        //        how do I do it in swift
        
        // Regular expression pattern to match the iframe tags and extract their attributes
        let pattern = #"src=\"https:\/\/www\.youtube\.com\/embed\/([A-Za-z0-9_-]+)\""#

        // Create an instance of NSRegularExpression
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        // Perform the regex match
        let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.count))
        
        // Process each match
        for match in matches {
            let range = match.range(at: 0)
            
            var src: String = (htmlString as NSString).substring(with: range)
            
            // Set up so that the video can run without an automatic full-screen mode.
            //https://stackoverflow.com/questions/27103454/how-to-add-a-character-at-a-particular-index-in-string-in-swift
            let index = src.index(before: src.endIndex)
            src = src.prefix(upTo: index) + "?&playsinline=1" + src.suffix(from: index)
            
            // Append the iframe information to the list
            videoURLs.append(src)
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case NEWS_SECTION:
            return 1
        case VIDEO_SECTION:
            return videoURLs.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case NEWS_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: NEWS_CELL, for: indexPath) as! NewsDetailTableViewCell

            guard let news, let articleContent = news.articleContent else {
                return cell
            }
            
            // Configure the cell...
            cell.titleLabel.text = news.title
            cell.shortDescLabel.text = news.shortDesc

            var htmlString = ""
            
            //        Prompt for chatgpt
            //        I have text
            //        this text has several or even none of <iframe ...> </iframe>
            //
            //        I want to store the information of that iframe in my list
            //
            //        how do I do it in swift
            
            if articleContent.contains("&gt;"){
                htmlString = articleContent.decoded
            } else {
                htmlString = articleContent.removeTags
            }
            print(htmlString)
            
            // delete the <iframe...></iframe> from htmlString and add newline
            htmlString = htmlString.removeIframe.addNewLine
            
            //Translate the html tag into attributed string
            if let attributedString = try? NSAttributedString(data: (htmlString.data(using: .utf8))!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil){
                
    //             Modify the image size
                attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length), options: [], using: { (value, range, stop) in
                    if let attachment = value as? NSTextAttachment{
                        if let fileWrapper = attachment.fileWrapper, let data = fileWrapper.regularFileContents, let image = UIImage(data: data) {
                            let maxWidth: CGFloat = cell.bounds.maxY - 35
                            let scaleFactor = maxWidth / image.size.width
                            let newSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)

                            attachment.bounds = CGRect(origin: attachment.bounds.origin, size: newSize)
                        }
                    }
                })
                cell.articleContentLabel.attributedText = attributedString
                cell.articleContentLabel.font = .systemFont(ofSize: cell.bounds.width / 25)
                cell.articleContentLabel.textAlignment = .justified
                cell.articleContentLabel.lineBreakMode = .byWordWrapping
            }
            return cell
        case VIDEO_SECTION:
            let cell = tableView.dequeueReusableCell(withIdentifier: VIDEO_CELL, for: indexPath) as! VideoTableViewCell
            
            cell.youtubeView.configuration.allowsInlineMediaPlayback.toggle()
            
            // process the video
            for videoURL in videoURLs{
                cell.youtubeView.loadHTMLString("<iframe width=\"\(cell.bounds.width*2.5)\" height=\"\(cell.bounds.height*2)\" \(videoURL) frameborder=\"0\" allowfullscreen playsinline></iframe>", baseURL: nil)
            }
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
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
