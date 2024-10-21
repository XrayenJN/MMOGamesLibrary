//
//  LoginViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  Login VC, ask user their email and password with the registred email in this application

import UIKit

class LoginViewController: UIViewController {
    weak var firebaseController: FirebaseProtocol?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signUpButton(_ sender: Any) {
        // Check whether the input is valid
        if !checkInputIntegrity(){
            displayMessage(title: "Input is incorrect", message: "You can't leave any field blank. You also can't have a different password for one account.")
            return
        }
        
        // get the email and password
        guard let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        // logIn using built-in method from Firebase
        self.firebaseController?.logIn(email: email, password: password, completion: { (finished) in
            // once the Task we have (async method from databaseController) is finished, do the segue
            if finished {
                self.performSegue(withIdentifier: "successfulLogin", sender: self)
            }
            
            // otherwise, show the erorr whether duplicate account or password is not strong
            if !finished {
                let _ = self.shouldPerformSegue(withIdentifier: "successfulSignUp", sender: self)
                self.displayMessage(title: "Error", message: "Wrong Email or Password")
            }
        })
    }

    // check if the email and password field has input or not
    func checkInputIntegrity() -> Bool {
        // check all the field is field
        return emailField.hasText && passwordField.hasText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
    }
    

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
