//
//  ProfileViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 11/5/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, DatabaseListener {

    @IBOutlet weak var notifToggle: UISwitch!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    var currentUser: User?
    // Storage for whether user enabled notifications
    let userDefaults = UserDefaults.standard

    let TOGGLE_STATE_KEY = "notifOn"
    let NOTIF_IDENTIFIER = "ofoods.notifs"
    let NOTIF_HOUR = 19
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.myUser
    let notificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMenu()

        // Check if the notification is enabled
        if userDefaults.bool(forKey: TOGGLE_STATE_KEY) == true {
            notifToggle.setOn(true, animated: true)
        } else {
            notifToggle.setOn(false, animated: true)
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        saveBtn.isHidden = true
        

        passTextField.text = "***********"
        userNameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        passTextField.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
    
    func setUpMenu() {
        // Set up edit profile action
        let edit = UIAction(title: "Edit Profle", image: UIImage(systemName: "pencil")) { _ in
            self.userNameTextField.isUserInteractionEnabled = true
            self.emailTextField.isUserInteractionEnabled = true
            self.passTextField.isUserInteractionEnabled = false
            self.saveBtn.isHidden = false
        }
        // Set up change password action
        let changePassword = UIAction(title: "Change Password", image: UIImage(systemName: "lock")) { _ in
            self.userNameTextField.isUserInteractionEnabled = false
            self.emailTextField.isUserInteractionEnabled = false
            self.passTextField.isUserInteractionEnabled = true
            self.passTextField.text = ""
            self.saveBtn.isHidden = false
        }

        // Set up confirmation for signing out
        let okAction = UIAlertAction(title: "Sign out", style: .default, handler: { (action) -> Void in
            self.navigationItem.title = "Signing out..."
            do {
                try Auth.auth().signOut()
            } catch {
                self.displayMessageError(title: "Sign out Error", message: "Authentication Failed with Error:\(String(describing: error))")
            }
        })
        // Set up cancel action for signing out
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button click...")
        }
        
        // Set up sign out action
        let signOut = UIAction(title: "Sign Out", image: UIImage(systemName: "rectangle.portrait.and.arrow.forward")) { _ in
            self.displayMessageConfirmation(title: "Are you sure you want to sign out?", message: nil, actions: [okAction, cancelAction])
        }
        
        // Configuring the menu
        let menu = UIMenu(children: [edit, changePassword, signOut])
        navigationItem.rightBarButtonItem = .init()
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "ellipsis")
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "Green")
        navigationItem.rightBarButtonItem?.menu = menu
    }

    func onMyUserChange(change: DatabaseChange, user: User) {
        currentUser = user
        userNameTextField.text = user.userName
        emailTextField.text = user.email
        
        userNameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        saveBtn.isHidden = true
    }
    
    // When user change the toggle for notifications
    @IBAction func onToggleChanged(_ sender: Any) {
        // If toggle is on, ask for notification authorization
        if notifToggle.isOn {
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
                if(!permissionGranted) {
                    self.displayMessageError(title: "Notification Permissions Denied",
                                             message: "Please grant permissions to receive notifications.")
                }
            }
            
            // Update toggle state in user defaults
            userDefaults.set(true, forKey: TOGGLE_STATE_KEY)
            
            let content = UNMutableNotificationContent()
                    content.title = "It's Dinner Time! Ready to Cook?"
                    content.body = "Your favourite recipes are waiting for you!"
                    content.sound = UNNotificationSound.default
            
            var triggerDate = DateComponents()
            triggerDate.hour = NOTIF_HOUR

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            let request = UNNotificationRequest(identifier: NOTIF_IDENTIFIER, content: content, trigger: trigger)
            
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Error : \(error.localizedDescription)")
                }
            })
        } else {
            // Remove all the pending notifs if toggle is turned off
            userDefaults.set(false, forKey: TOGGLE_STATE_KEY)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [NOTIF_IDENTIFIER])
        }
    }
    
    func isValidPassword(password: String) -> Bool {
        return password.count >= 6
    }

    // Saving the edited details
    @IBAction func onClickSaveBtn(_ sender: UIButton) {
        guard userNameTextField.text?.isEmpty == false, emailTextField.text?.isEmpty == false, passTextField.text?.isEmpty == false else {
            displayMessageError(title: "Missing Fields", message: "Some of userName, email or password fields are empty.")
            return
        }
        
        if let currentUser = currentUser {
            // Check if edit was on password or profile info
            if passTextField.isUserInteractionEnabled == true {
                if let newPassword =  passTextField.text, isValidPassword(password: newPassword) {
                    databaseController?.updatePassword(newPass: passTextField.text!)
                    saveBtn.isHidden = true
                    passTextField.isUserInteractionEnabled = false
                } else {
                    displayMessageError(title: "Invalid Password", message: "Please make sure your password is at least 6 characters")
                }
            } else {
                currentUser.userName = userNameTextField.text
                currentUser.email = emailTextField.text
                if databaseController?.updateUser(user: currentUser) == true {
                    displayMessageError(title: "Saved User Info", message: "Successful!")
                }
            }
        }
        
    }

    
    func onUsersChange(change: DatabaseChange, users: [User]) {}
    func onMyRecipesChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onSharedRecipeWithUsersChange(change: DatabaseChange, sharedRecipes: [SharedRecipe]) {}
    func onSharedRecipesChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onImageLoaded(recipe: Recipe) {}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
