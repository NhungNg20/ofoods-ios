//
//  ViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 21/4/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var passTextFields: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func onClickLoginBtn(_ sender: UIButton) {
        guard let password = passTextFields.text, password.isEmpty == false else {
            displayMessageError(title: "Login Error", message: "Please enter your password.")
            return
        }
        guard let email = emailTextField.text, email.isEmpty == false else {
            displayMessageError(title: "Login Error", message: "Please enter your email.")
            return
        }

        sender.setTitle("Logging in...", for: .normal)

        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
            } catch {
                sender.setTitle("Login", for: .normal)
                // Check an error occurred, if so, respond accordingly
                if let err = error as NSError? {
                    let errCode = AuthErrorCode(_nsError: err)
                    switch errCode.code {
                        case .invalidEmail, .wrongPassword:
                            displayMessageError(title: "Login Error", message: "Wrong email address or password.")
                        case .networkError:
                            displayMessageError(title: "Network Error", message: "Please try logging in again.")
                        default:
                            displayMessageError(title: "Login Error", message: "Something went wrong, please try logging in again.")
                    }
                }
            }
        }
    }
    
}

