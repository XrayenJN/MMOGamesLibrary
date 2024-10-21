//
//  DatabaseProtocol.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  Protocol for firebase connection

import Foundation


enum FirebaseListenerType{
    case auth           // auth related connection
    case wishlist       // wishlist games related
    case savedGames     // savedgames related
    case all            // want to retrieve the wishlsit and savedgames at the same time.
}

enum DatabaseChange{
    case add            // add the data to firebase
    case update         // update the existed data from firebase
    case remove         // remove data from firebase
}

protocol FirebaseListener: AnyObject{
    // 'marker' for each VC who want to get a related data (based on the FirebaseListenerType)
    var firebaseListenerType: FirebaseListenerType {get set}
    
    func onAuthStateChange(newAuthState: Bool)                          // update the auth state for the related VC
    func onWishlistChange(change: DatabaseChange, wishlist: [Int])      // update the wishlist (list) for the related VC
    func onSavedGamesChange(change: DatabaseChange, savedGames: [Int])  // update the saved games (list) for the related VC
}

protocol FirebaseProtocol: AnyObject{
    func addListener(listener: FirebaseListener)    // add listener to the VC
    func removeListener(listener: FirebaseListener) // remove listener from the VC
    
    func logIn(email: String, password: String, completion:@escaping(_ finished:Bool) -> Void)      // Log in function
    func signUp(email: String, password: String, completion:@escaping(_ finished: Bool) -> Void)    // sign Up function
    func logout()   // logout user
    
    func addUser(userUID: String)                   // add user to the firebase
    func addGameToSavedGames(gameID: Int) -> Bool   // add game to the saved games' user list
    func removeGameFromSavedGames(gameID: Int)      // remove game from saved games
    func addGameToWishlist(gameID: Int) -> Bool     // add game to wishlist
    func removeGameFromWishlist(gameID: Int)        // remove from wishlist (of the logged user)
}
