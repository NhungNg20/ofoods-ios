//
//  SearchIngredientsTableViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 4/5/2023.
//

import UIKit

class SearchIngredientsTableViewController: UITableViewController, UISearchBarDelegate, RecipeUpdateDelegate {
    
    var indicator = UIActivityIndicatorView()
    // The selected ingredient
    var selectedIngredient: IngredientData?
    var searchResults: [IngredientData] = [IngredientData]()
    var ingredients: [Ingredient]?
    var delegate: RecipeUpdateDelegate?
    
    let CELL_RESULT = "resultCell"
    
    // The search ingredients API URL
    let SCHEME = "https"
    let HOST = "api.spoonacular.com"
    let API_KEY = "2d8b25a39fdc49eba4ba232159819d1d"
    let MAX_ITEMS = 100
    //    var searchTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = false
        
        // Add a search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "e.g., Strawberries"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
    
    // If an ingredient was added, let listeners know
    func ingredientsUpdated(ingredients: [Ingredient]) {
        self.ingredients = ingredients
        delegate?.ingredientsUpdated(ingredients: ingredients)
    }
    
    func directionsUpdated(directions: [Step]) {}
    
    // Search an ingredient according to the search term
    func searchIngredientNamed(_ searchTerm: String) async {
        // Build the URL
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = SCHEME
        searchURLComponents.host = HOST
        searchURLComponents.path = "/food/ingredients/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "number", value: "\(MAX_ITEMS)"),
            URLQueryItem(name: "apiKey", value: API_KEY)
        ]
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // Get the data
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            do {
                // Decode the response to an ingredient data object
                let decoder = JSONDecoder()
                let results = try decoder.decode(IngredientResultData.self, from: data)
                // If sucessfully, deocoded, add to the search results
                if let ingredients = results.ingredients, ingredients.isEmpty == false {
                    ingredients.forEach { ingredient in
                        ingredient.name = ingredient.name.capitalized
                    }
                    searchResults.append(contentsOf: ingredients)
                }
                // Reload to the table view in a different thread
                Task {
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                }
            } catch let error {
                print(error)
            }
        } catch let error {
            print(error)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        tableView.reloadData()
        guard let searchText = searchBar.text else {
            return
        }
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        Task {
            URLSession.shared.invalidateAndCancel()
            await searchIngredientNamed(searchText)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RESULT, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let result = searchResults[indexPath.row]
        content.text = result.name
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Allow users to determine the UOM of the selected ingredient
        let cell = tableView.cellForRow(at: indexPath)
        selectedIngredient = searchResults[indexPath.row]
        performSegue(withIdentifier: "popOverSegue", sender: cell)
        cell?.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchResults.count > 0 {
            if searchResults.count == 1 {
                return "1 Ingredient"
            } else {
                return "\(searchResults.count) Ingredients"
            }
        } else {
            return nil
        }
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popOverSegue" {
            let destination = segue.destination as! UOMViewController
            destination.ingredients = ingredients
            destination.ingredientName = selectedIngredient!.name
            destination.delegate = self
        }
    }
}
