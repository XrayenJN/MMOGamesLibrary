//
//  FirebaseController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  Firebase Controller, connect to the firebase, retrieve or send the data from or into firebase

import UIKit
import Firebase
import FirebaseFirestoreSwift


class FirebaseController: NSObject, FirebaseProtocol {
    // variable for the connection
    var authController: Auth
    
    // logged in user
    var currentUser: FirebaseAuth.User?
    var listeners = MulticastDelegate<FirebaseListener>()
    
    // Variables for connecting with Firestore
    var database: Firestore
    var usersRef: CollectionReference?
    
    // variables to store temporarily the data that we get from firebase
    var savedGames: [Int]
    var wishlist: [Int]

    override init() {
        // Sync with the Firebase itself
        FirebaseApp.configure()
        
        // get the authentication from firebase
        self.authController = Auth.auth()
        if let loggedInUser = authController.currentUser {
            currentUser = loggedInUser
        }
        
        // Establish connection with firestore
        database = Firestore.firestore()
        savedGames = [Int]()
        wishlist = [Int]()
        usersRef = database.collection("user")
            
        super.init()
        
        if let currentUser {
            setupSavedGamesAndWishlist()
        }
    }
    
    // listener function so every VC that have this listener, will be affected
    // affected in a way that they will retrieve the information they need
    func addListener(listener: FirebaseListener){
        // used to get the state of current user whether it is auth or not
        if listener.firebaseListenerType == .auth {
            if currentUser != nil{
                listener.onAuthStateChange(newAuthState: true)
            } else {
                listener.onAuthStateChange(newAuthState: false)
            }
        }
        // for saved games list
        if listener.firebaseListenerType == .savedGames || listener.firebaseListenerType == .all{
            listener.onSavedGamesChange(change: .update, savedGames: savedGames)
        }
        
        // for wishlist
        if listener.firebaseListenerType == .wishlist || listener.firebaseListenerType == .all {
            listener.onWishlistChange(change: .update, wishlist: wishlist)
        }
    }
    
    // once VC is closed (bcs user moved into another VC, those listener will be removed)
    // --> reduce the load work
    func removeListener(listener: FirebaseListener){
        // VC don't have to listen to this anymore once we move into another vc
        listeners.removeDelegate(listener)
        if listener.firebaseListenerType == .auth {
            authController.removeStateDidChangeListener(authController)
        }
    }
    
    // Login function, built-in from firebase (mostly)
    func logIn(email: String, password: String, completion:@escaping(_ finished:Bool) -> Void){
        // authController.signIn is the builtin function from firebase
        authController.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            // Completion will be used by the VC who use this function. Works similiar with await
            if error == nil {
                if let user {
                    print("\(user.user.uid) has signed in successfully!")

                    // this completion is needed because the log in itself takes time
                    // so in a way that user wait in the login VC first before continue to the corresponding VC
                    // we use this completion boolean
                    completion(true)
                    self.currentUser = user.user
                    self.usersRef = self.database.collection("user")
                    
                    // Change the user state
                    self.listeners.invoke { (listener) in
                        if listener.firebaseListenerType == .auth {
                            listener.onAuthStateChange(newAuthState: true)
                        }
                    }
                    
                    // get the saved games and wishlist from the related user (user who just logged in)
                    self.setupSavedGamesAndWishlist()
                }
            } else {
                // otherwise, we can just say pop up message
                // popup message will be shown in the outer function (who called this function)
                print(error!.localizedDescription)
                
                // completion false so user can't access any area of the application that need auth
                completion(false)
            }
        })
    }
    
    func signUp(email: String, password: String, completion:@escaping(_ finished: Bool) -> Void){
        // creating user from scratch with a unique email
        authController.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            // Completion will be used by the VC who use this function. Works similiar with await
            if error == nil {
                if let user {
                    print("\(user.user.uid) has signed in successfully!")

                    // this completion is needed because the log in itself takes time
                    // so in a way that user wait in the login VC first before continue to the corresponding VC
                    // we use this completion boolean
                    completion(true)
                    self.currentUser = user.user
                    self.usersRef = self.database.collection("user")
                    
                    // create a new document in firestore
                    self.addUser(userUID: user.user.uid)
                    
                    // Change the user state
                    self.listeners.invoke { (listener) in
                        if listener.firebaseListenerType == .auth {
                            listener.onAuthStateChange(newAuthState: true)
                        }
                    }
                    
                    // get the saved games and wishlist from the related user (user who just logged in)
                    self.setupSavedGamesAndWishlist()
                }
            } else {
                // otherwise, we can just say pop up message
                // popup message will be shown in the outer function (who called this function)
                print(error!.localizedDescription)
                
                // completion false so user can't access any area of the application that need auth
                completion(false)
            }
        })
    }
    
    // logout user
    func logout(){
        do {
            // inbuilt-function
            try authController.signOut()
            
            // set the user to nil so it doesn't messed up in some way
            currentUser = nil
            usersRef = nil
            
            // change the user state
            self.listeners.invoke { (listener) in
                if listener.firebaseListenerType == .auth {
                    listener.onAuthStateChange(newAuthState: false)
                }
            }
            print("Successfully Sign Out")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    // Feature of Wishlist and SavedGames
    func addUser(userUID: String) {
        // this function to create a space in firebase.
        if let user = currentUser, let usersRef {
            let userRef = usersRef.document(user.uid)
            
            let data: [String: Any] = [
                "savedGames": [Int](),
                "wishlist": [Int](),
            ]
            
            userRef.setData(data)
        }
        
    }
    
    // adding the game to the saved games list in the firebase
    func addGameToSavedGames(gameID: Int) -> Bool {
        // if there is no user logged in, can't do this
        guard let currentUser, let usersRef else {
            return false
        }
        
        let userRef = usersRef.document(currentUser.uid)
        userRef.updateData(["savedGames": FieldValue.arrayUnion([gameID])])
        
        return true
    }
    
    // remove the game from the saved games list in the firebase
    func removeGameFromSavedGames(gameID: Int) {
        // if there is no user logged in, can't do this
        guard let currentUser, let usersRef else {
            return
        }
        
        let userRef = usersRef.document(currentUser.uid)
        userRef.updateData(["savedGames": FieldValue.arrayRemove([gameID])])
    }
    
    // adding game to the wishlist in the firebase
    func addGameToWishlist(gameID: Int) -> Bool {
        // if there is no user logged in, can't do this
        guard let currentUser, let usersRef else {
            return false
        }
        
        let userRef = usersRef.document(currentUser.uid)
        userRef.updateData(["wishlist": FieldValue.arrayUnion([gameID])])
        
        return true
    }
    
    // remove the game from the wishlist in the firebase
    func removeGameFromWishlist(gameID: Int) {
        // if there is no user logged in, can't do this
        guard let currentUser, let usersRef else {
            return
        }
        
        let userRef = usersRef.document(currentUser.uid)
        userRef.updateData(["wishlist": FieldValue.arrayRemove([gameID])])
    }
    
    // Retrieve data from firebase especially the savedgames and wishlist (games)
    func setupSavedGamesAndWishlist() {
        guard let usersRef, let currentUser else {
            return
        }
        
        usersRef.document(currentUser.uid).addSnapshotListener{ (querySnapshot, error) in
            guard let querySnapshot else {
                print("ErrOr Fetching users: \(String(describing: error))")
                return
            }
            
            self.parseUsersSnapshot(snapshot: querySnapshot)
        }
    }
    
    // this method is used to parse the data that we get from firebase itself.
    func parseUsersSnapshot(snapshot: DocumentSnapshot){
        guard let snapshot = snapshot.data(), let getWishlist = snapshot["wishlist"] as? [Int], let getSavedGames = snapshot["savedGames"] as? [Int] else {
            return
        }
        
        wishlist = getWishlist
        savedGames = getSavedGames
        
        // invoke to any listener (VC) that use those enum, so they can get any related information.
        listeners.invoke { (listener) in
            if listener.firebaseListenerType == FirebaseListenerType.wishlist || listener.firebaseListenerType == FirebaseListenerType.all {
                listener.onWishlistChange(change: .update, wishlist: wishlist)
            }
            if listener.firebaseListenerType == FirebaseListenerType.savedGames || listener.firebaseListenerType == FirebaseListenerType.all {
                listener.onSavedGamesChange(change: .update, savedGames: savedGames)
            }
        }
        
    }
}
