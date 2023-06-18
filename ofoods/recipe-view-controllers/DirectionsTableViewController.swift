//
//  DirectionsTableViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

class DirectionsTableViewController: UITableViewController, RecipeUpdateDelegate {

    var directions: [Step]?
    var delegate: RecipeUpdateDelegate?
    let CELL_STEP = "stepCell"
    var isView: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the directions array
        if directions == nil {
            directions = [Step]()
        }
        
        if let noOfSteps = directions?.count {
            navigationItem.title = "\(noOfSteps) Steps"
        }
        
        // Disable editing if recipe viewing
        if let isView = isView, isView == true {
            tableView.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func ingredientsUpdated(ingredients: [Ingredient]) {}
    
    func directionsUpdated(directions: [Step]) {
        self.directions = directions
        navigationItem.title = "\(directions.count ) Steps"
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let directions = directions, directions.isEmpty == false {
            return directions.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_STEP, for: indexPath)
        var content = cell.defaultContentConfiguration()

        if let directions = directions, directions.isEmpty == false {
            let step = directions[indexPath.row]
            content.text = "Step \(String(indexPath.row + 1))"
            content.secondaryText = step.detail
            tableView.allowsSelection = true
        } else {
            content.text = "No directions yet. Tap + to add some."
            tableView.allowsSelection = false
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
            directions?.remove(at: indexPath.row)
            if let noOfSteps = directions?.count {
                navigationItem.title = "\(noOfSteps) Steps"
            }
            tableView.reloadData()
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewStepSegue" {
            let destination = segue.destination as! StepViewController
            destination.delegate = self
            destination.directions = directions
        } else if segue.identifier == "showStepSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let destination = segue.destination as! StepViewController
                destination.delegate = self
                destination.directions = directions
                destination.step = directions?[indexPath.row]
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Do not show the step vc if there are not steps yet
        if identifier == "showStepSegue" && (directions?.isEmpty)! {
            return false
        }
        return true
    }

}
