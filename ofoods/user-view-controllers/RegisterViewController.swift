//
//  RegisterViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 11/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        emailTextField.becomeFirstResponder()
    }
    
    
    @IBAction func onClickRegisterBtn(_ sender: UIButton) {
        guard let password = newPassTextField.text, password.isEmpty == false else {
            displayMessageError(title: "Registration Error", message: "Please enter a password.")
            return
        }
        
        guard let email = emailTextField.text, email.isEmpty == false else {
            displayMessageError(title: "Registration Error", message: "Please enter an email.")
            return
        }
        
        guard let userName = userNameTextField.text, userName.isEmpty == false else {
            displayMessageError(title: "Registration Error", message: "Please enter a user name.")
            return
        }
        
        if let confirmPassword = confirmPassTextField.text, confirmPassword == password {
            sender.setTitle("Registering...", for: .normal)
            Task {
                do {
                    let result = try await Auth.auth().createUser(withEmail: email, password: password)
                    let newUser = User(id: result.user.uid, userName: userName, email: result.user.email, recipes: [DocumentReference]())
                    let _ = self.databaseController?.addNewUser(user: newUser)
                } catch {
                    sender.setTitle("Register", for: .normal)
                    // Check an error occurred, if so, respond accordingly
                    if let err = error as NSError? {
                        let errCode = AuthErrorCode(_nsError: err)
                        switch errCode.code {
                        case .invalidEmail:
                            displayMessageError(title: "Sign up Error", message: "Invalid email address.")
                        case .networkError:
                            displayMessageError(title: "Network Error", message: "Please try logging in again.")
                        case .emailAlreadyInUse:
                            displayMessageError(title: "Sign up Error", message: "Email already in use, please sign up with another email")
                        case .weakPassword:
                            displayMessageError(title: "Sign up Error", message: err.localizedDescription)
                        default:
                            displayMessageError(title: "Sign up Error", message: "Something went wrong, please try logging in again.")
                        }
                    }
                }
            }
        } else {
            displayMessageError(title: "Registration Error", message: "Please confirm your password.")
            return
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
