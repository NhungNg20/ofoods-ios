//
//  IngredientsTableViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

class IngredientsTableViewController: UITableViewController, RecipeUpdateDelegate {
    var ingredients: [Ingredient]?
    var delegate: RecipeUpdateDelegate?
    let CELL_INGRED = "ingredientCell"
    var isView: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create ingredient if it doesn't exist
        if ingredients == nil {
            ingredients = [Ingredient]()
        }
        
        if let noOfIngredients = ingredients?.count {
            navigationItem.title = "\(noOfIngredients) Ingredients"
        }
        
        // Disable interaction if viewing the recipe
        if let isView = isView, isView == true {
            tableView.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem = nil
        }
    }

    
    func ingredientsUpdated(ingredients: [Ingredient]) {
        self.ingredients = ingredients
        navigationItem.title = "\(ingredients.count) Ingredients"
        tableView.reloadData()
    }
    
    func directionsUpdated(directions: [Step]) {}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let noOfIngredients = ingredients?.count, noOfIngredients > 0 {
            return noOfIngredients
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INGRED, for: indexPath)
        var content = cell.defaultContentConfiguration()

        if let ingredients = ingredients, ingredients.isEmpty == false {
            let ingredient = ingredients[indexPath.row]
            content.text = ingredient.name
            content.secondaryText = "\(ingredient.quantity!) \(ingredient.unit!) "
            tableView.allowsSelection = true
        } else {
            content.text = "No ingredients yet. Tap + to add some."
            tableView.allowsSelection = false
        }

        cell.contentConfiguration = content
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ingredients?.remove(at: indexPath.row)
            if let noOfIngredients = ingredients?.count {
                navigationItem.title = "\(noOfIngredients) Ingredients"
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Allow for editing of an ingredient
        performSegue(withIdentifier: "editIngredSegue", sender: tableView.cellForRow(at: indexPath))
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchIngredientsSegue" {
            let destination = segue.destination as! SearchIngredientsTableViewController
            destination.ingredients = ingredients
            destination.delegate = self
        } else if segue.identifier == "editIngredSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let destination = segue.destination as! UOMViewController
                destination.ingredients = ingredients
                destination.ingredient = ingredients?[indexPath.row]
                destination.delegate = self
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Do not edit an ingredient if no ingredients
        if identifier == "editIngredSegue" && (ingredients?.isEmpty)! {
            return false
        }
        return true
    }

}
