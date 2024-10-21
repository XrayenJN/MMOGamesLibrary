//
//  ProfileTableViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  TableView Controller, on the right panel of the main VC

import UIKit

class ProfileTableViewController: UITableViewController, FirebaseListener {
    func onWishlistChange(change: DatabaseChange, wishlist: [Int]) {
        // Do nothing
    }
    
    func onSavedGamesChange(change: DatabaseChange, savedGames: [Int]) {
        // Do nothing
    }
    
    // static variable
    let SECTION_NON_AUTH = 0
    let SECTION_AUTH = 1
    
    let CELL_NON_AUTH = "nonAuthCell"
    let CELL_AUTH = "authCell"
    
    // use listener for sync the auth status with the databaseController
    var firebaseListenerType: FirebaseListenerType = .auth
    weak var firebaseController: FirebaseController?
    var authState: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the databaseOntroller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup the listener so everytime we launch this VC, we will sync the auth state
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove the listener because we don't need it anymore once we move to another VC
        super.viewWillDisappear(animated)
        firebaseController?.removeListener(listener: self)
    }

    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
        // Just go back to this VC
    }

    
    // MARK: - Functions from DatabaseListener: listen any changes from database
    func onAuthStateChange(newAuthState: Bool) {
        authState = newAuthState
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        // SHOWING THE NON-USER log in
        case SECTION_NON_AUTH:
            // if the user doesnt log in
            if authState {
                return 0
            } else {
                // show this section
                return 1
            }
        // SHOWING the USER Log in
        case SECTION_AUTH:
            // if the user log in
            if authState{
                //show this section
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create the cell based on the auth situation
        if indexPath.section == SECTION_NON_AUTH{
            // show user to log in or sign up
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_NON_AUTH, for: indexPath) as! NonUserAuthTableViewCell
            
            return cell
        } else {
            // show user the saved games and wishlist part
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_AUTH, for: indexPath) as! UserAuthTableViewCell
            cell.firebaseController = firebaseController
            
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
        if segue.identifier == "savedGamesSegue" {
            let destination = segue.destination as! UserGamesLibraryTableViewController
            destination.identity = destination.SAVED_GAMES_IDENTITY
        }
        if segue.identifier == "wishlistSegue" {
            let destination = segue.destination as! UserGamesLibraryTableViewController
            destination.identity = destination.WISHLIST_IDENTITY
        }
    }
    

}
