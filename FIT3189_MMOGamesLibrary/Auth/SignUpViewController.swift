//
//  SignUpViewController.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 2/5/2023.
//  Signup VC , ask user to put email and password to create an account for this application

import UIKit

class SignUpViewController: UIViewController {
    weak var fireBaseController: FirebaseProtocol?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
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
        
        // signUp using built-in method from Firebase
        self.fireBaseController?.signUp(email: email, password: password, completion: { (finished) in
            // once the Task we have (async method from databaseController) is finished, do the segue
            if finished {
                self.performSegue(withIdentifier: "successfulSignUp", sender: self)
            }
            
            // otherwise, show the erorr whether duplicate account or password is not strong
            if !finished {
                let _ = self.shouldPerformSegue(withIdentifier: "successfulSignUp", sender: self)
                self.displayMessage(title: "Error", message: "Duplicate Email! Password strength is not enough!")
            }
        })
        
    }

    // check the input integrity, whether the input is valid or not (blank or not)
    func checkInputIntegrity() -> Bool {
        // check all the field is field
        let noBlankInput = emailField.hasText && passwordField.hasText && password2Field.hasText
        
        // check if password 1 and password 2 are same
        let samePassword = passwordField.text == password2Field.text
        return noBlankInput && samePassword
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        fireBaseController = appDelegate?.firebaseController
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
