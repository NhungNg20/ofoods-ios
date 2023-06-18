//
//  MyRecipesViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 7/5/2023.
//

import UIKit

class MyRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                               UISearchResultsUpdating, DatabaseListener {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    // All users
    var allUsers: [User]?
    // The current recipe being shown
    var recipes: [Recipe] = []
    // The current user's recipes
    var myRecipes: [Recipe] = []
    // The recipes shared from other users
    var sharedRecipes: [Recipe] = [Recipe]()
    // The recipes filtered through search bar
    var filteredRecipe: [Recipe] = []
    var indicator = UIActivityIndicatorView()
    
    var listenerType = ListenerType.myRecipes
    weak var databaseController: DatabaseProtocol?
    
    let SEGMENT_MINE = 0
    let SEGMENT_SHARED = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        filteredRecipe = recipes
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        // Check which segment was chosen, update view accordingly
        if isMyRecipesShown() {
            recipes = myRecipes
        } else {
            recipes = sharedRecipes
        }
        updateSearchResults(for: navigationItem.searchController!)
    }

    func onImageLoaded(recipe: Recipe) {
        updateSearchResults(for: self.navigationItem.searchController!)
    }
    
    func onMyRecipesChange(change: DatabaseChange, recipes: [Recipe]) {
        self.myRecipes = recipes
        if isMyRecipesShown() {
            self.recipes = myRecipes
            updateSearchResults(for: navigationItem.searchController!)
        }
        indicator.stopAnimating()
    }
    
    func onUsersChange(change: DatabaseChange, users: [User]) {
        allUsers = users
    }
    
    func onSharedRecipesChange(change: DatabaseChange, recipes: [Recipe]) {
        self.sharedRecipes = recipes
        if !isMyRecipesShown() {
            self.recipes = sharedRecipes
            updateSearchResults(for: navigationItem.searchController!)
        }
        indicator.stopAnimating()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredRecipe = recipes.filter({ (recipe: Recipe) -> Bool in
                return (recipe.title?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredRecipe = recipes
        }
        tableView.reloadData()
    }
    
    // Check with segment is selected
    func isMyRecipesShown() -> Bool {
        return segmentControl.selectedSegmentIndex == SEGMENT_MINE
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (recipes.isEmpty) {
            return 0
        }
        return filteredRecipe.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeTableViewCell
        let recipe = filteredRecipe[indexPath.row]
        cell.recipeNameLabel.text =  recipe.title
        if let image = recipe.image {
            cell.recipeImage.image = image
        } else {
            cell.recipeImage.image = nil
        }
        
        let cookTime = recipe.cookTimeInMins ?? 0
        let servings = recipe.servings ?? 0
        let story = recipe.story ?? ""
        cell.timeServingLabel.text =  "\(cookTime) min | \(servings) Servings"
        cell.storyLabel.text = "\(story.prefix(20))..."
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        performSegue(withIdentifier: "viewRecipeSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(recipes.count) Recipes"
    }
    
    func onMyUserChange(change: DatabaseChange, user: User) {}
    func onSharedRecipeWithUsersChange(change: DatabaseChange, sharedRecipes: [SharedRecipe]) {}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let recipe = recipes[indexPath.row]
    
        if segue.identifier == "viewRecipeSegue" {
            let destination = segue.destination as! ViewRecipeViewController
            destination.recipe = recipe
            // If the selected recipe is a shared one, do not give the user the option to edit
            if !myRecipes.contains(recipe) {
                destination.isShared = true
                // Add the original author
                destination.author = allUsers?.first(where: {user in recipe.authorId == user.id})
            }
        }
    }

}
