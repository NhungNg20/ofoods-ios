//
//  SearchUsersTableViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 6/6/2023.
//

import UIKit

class SearchUsersTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {

    let CELL_USER = "userCell"
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    var sharedUsers: [User]?
    var recipe: Recipe?
    var indicator = UIActivityIndicatorView()
    
    var listenerType = ListenerType.users
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        filteredUsers = allUsers

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Adding search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        if (allUsers.isEmpty) {
            indicator.startAnimating()
        }
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
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        if searchText.count > 0 {
            filteredUsers = allUsers.filter({ (user: User) -> Bool in
                return user.userName?.lowercased().contains(searchText) ?? false
            })
        } else {
            filteredUsers = allUsers
        }
        tableView.reloadData()
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allUsers.isEmpty {
            return 0
        }
        return allUsers.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
        var content = cell.defaultContentConfiguration()

        let user = allUsers[indexPath.row]
        content.text = user.userName
        content.secondaryText = user.email

        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = allUsers[indexPath.row]
        let isAlreadyShared = sharedUsers?.allSatisfy() { user in
            return user.id != selectedUser.id
        }
        if let userName = selectedUser.userName {
            guard let isAlreadyShared = isAlreadyShared, isAlreadyShared else {
                self.displayMessageError(title: "Cannot Share Twice", message: "You've already shared this recipe with \(userName)")
                tableView.cellForRow(at: indexPath)?.selectionStyle = .none
                return
            }
            
            let okAction = UIAlertAction(title: "Share Recipe", style: .default, handler: { (action) -> Void in
                print("Ok button click...")
                if let recipeId = self.recipe?.id, let userId = selectedUser.id {
                    if self.databaseController!.shareRecipe(recipeId: recipeId, userId: userId) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button click...")
            }
            displayMessageConfirmation(title: "Share recipe with \(userName)?", message: nil, actions: [okAction, cancelAction])
        }
    }

    func onUsersChange(change: DatabaseChange, users: [User]) {
        allUsers = users
        indicator.stopAnimating()
        updateSearchResults(for: navigationItem.searchController!)
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
    
    func onMyRecipesChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onMyUserChange(change: DatabaseChange, user: User) {}
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
