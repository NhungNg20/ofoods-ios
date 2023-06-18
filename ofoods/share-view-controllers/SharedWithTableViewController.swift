//
//  SharedWithTableViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 6/6/2023.
//

import UIKit

class SharedWithTableViewController: UITableViewController, DatabaseListener {
    
    let CELL_USER = "sharedUserCell"
    var sharedRecipeRecords: [SharedRecipe] = []
    var sharedUsers: [User] = []
    var allUsers: [User] = []
    var recipe: Recipe?
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sharedRecipeWithUsers

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        databaseController?.removeListener(listener: self)
    }
    
    func onSharedRecipeWithUsersChange(change: DatabaseChange, sharedRecipes: [SharedRecipe]) {
        sharedRecipeRecords = sharedRecipes
        var sharedUsersList = [User]()
        // Get the shared records of current recipe
        let filteredSharedRecipe = sharedRecipes.filter({ (sharedRecipe: SharedRecipe) -> Bool in
            return (sharedRecipe.recipeId == recipe?.id)
        })
        // Loop through all shared records of recipe
        filteredSharedRecipe.forEach() { (sharedRecipe) in
            // Get the user
            let sharedUser = allUsers.first() { (user) in
                return user.id == sharedRecipe.userId
            }
            if let sharedUser = sharedUser {
                sharedUsersList.append(sharedUser)
            }
        }
        self.sharedUsers = sharedUsersList
        tableView.reloadData()
    }
    
    func onUsersChange(change: DatabaseChange, users: [User]) {
        allUsers = users
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sharedUsers.isEmpty {
            return 1
        }
        return sharedUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
        var content = cell.defaultContentConfiguration()

        if sharedUsers.isEmpty == false {
            let user = sharedUsers[indexPath.row]
            content.text = user.userName
            content.secondaryText = user.email
        } else {
            content.text = "You have not shared this recipe yet. Tap + to share."
        }

        cell.contentConfiguration = content
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = sharedUsers[indexPath.row]
            // Get the shared record between recipe and user to delete
            let sharedRecord = sharedRecipeRecords.first(where: { sharedRecipe in
                return sharedRecipe.recipeId == recipe?.id && sharedRecipe.userId == user.id
            })
            if let sharedRecordId = sharedRecord?.id {
                databaseController?.removeSharing(sharedRecipeId: sharedRecordId)
            }
            tableView.reloadData()
        }
    }

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
    
    func onMyRecipesChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onMyUserChange(change: DatabaseChange, user: User) {}
    func onSharedRecipesChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onImageLoaded(recipe: Recipe) {}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchUsersSegue" {
            let destination = segue.destination as! SearchUsersTableViewController
            destination.recipe = recipe
            destination.sharedUsers = sharedUsers
        }
    }
}
