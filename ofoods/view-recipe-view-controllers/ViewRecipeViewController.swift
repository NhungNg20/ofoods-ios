//
//  ViewRecipeViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 2/6/2023.
//

import UIKit

class ViewRecipeViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var directionsContainer: UIView!
    @IBOutlet weak var summaryContainer: UIView!
    @IBOutlet weak var ingredientsContainer: UIView!
    var recipe: Recipe?
    var author: User?
    // If the recipe is a shared one
    var isShared: Bool?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // If the recipe is not shared, the user can edit/share/delete
        if isShared != true {
            setUpMenu()
        }
        navigationItem.title = recipe?.title
        
        summaryContainer.alpha = 1
        ingredientsContainer.alpha = 0
        directionsContainer.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setUpMenu() {
        let edit = UIAction(title: "Edit Recipe", image: UIImage(systemName: "pencil")) { _ in
            self.performSegue(withIdentifier: "editRecipeSegue", sender: nil)
        }
        
        let share = UIAction(title: "Share with...", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.performSegue(withIdentifier: "shareRecipeSegue", sender: nil)
        }
        
        let okAction = UIAlertAction(title: "Delete Recipe", style: .default, handler: { (action) -> Void in
            print("Ok button click...")
            if let recipe = self.recipe, let databaseController = self.databaseController {
                databaseController.deleteRecipe(recipe: recipe)
            }
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button click...")
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "minus")) { _ in
            if let title = self.recipe?.title {
                self.displayMessageConfirmation(title: "Are you sure you want to delete recipe \(title)?", message: nil, actions: [okAction, cancelAction])
            }
        }
        let menu = UIMenu(children: [edit, share, delete])
        navigationItem.rightBarButtonItem = .init()
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "ellipsis")
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "Green")
        navigationItem.rightBarButtonItem?.menu = menu
    }
    
    @IBAction func onSegmentValueChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 1:
            UIView.animate(withDuration: 0.5, animations: {
                self.summaryContainer.alpha = 0
                self.ingredientsContainer.alpha = 1
                self.directionsContainer.alpha = 0
            })
        case 2:
            UIView.animate(withDuration: 0.5, animations: {
                self.summaryContainer.alpha = 0
                self.ingredientsContainer.alpha = 0
                self.directionsContainer.alpha = 1
            })
        default:
            UIView.animate(withDuration: 0.5, animations: {
                self.summaryContainer.alpha = 1
                self.ingredientsContainer.alpha = 0
                self.directionsContainer.alpha = 0
            })
        }
    }
    
    @IBAction func onClickExitBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "editRecipeSegue":
            let destination = segue.destination as! NewRecipeViewController
            destination.recipe = self.recipe!
            destination.isEdited = true
            destination.navigationItem.title = "Edit Recipe"
        case "viewInfoSegue":
            let destination = segue.destination as! InfoViewController
            destination.recipe = self.recipe!
            destination.isView = true
            // If its a shared recipe, there will be an author property
            destination.author = author
        case "viewIngredSegue":
            let destinationNav = segue.destination as! UINavigationController
            let destination = destinationNav.viewControllers.first as! IngredientsTableViewController
            destination.ingredients = self.recipe!.ingredients
            destination.isView = true
        case "viewDirSegue":
            let destinationNav = segue.destination as! UINavigationController
            let destination = destinationNav.viewControllers.first as! DirectionsTableViewController
            destination.directions = self.recipe!.directions
            destination.isView = true
        case "shareRecipeSegue":
            let destination = segue.destination as! SharedWithTableViewController
            destination.recipe = recipe
        default:
            return
        }
    }
    
}
