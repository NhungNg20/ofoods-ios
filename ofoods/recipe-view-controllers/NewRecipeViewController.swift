//
//  NewRecipeViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 6/5/2023.
//

import UIKit
import Firebase

class NewRecipeViewController: UIViewController {

    @IBOutlet weak var summaryContainer: UIView!
    @IBOutlet weak var ingredientsContainer: UIView!
    @IBOutlet weak var directionsContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    weak var databaseController: DatabaseProtocol?
    var recipe: Recipe = Recipe()
    var isEdited: Bool?
    
    // Child controllers in the container view
    var infoViewController: InfoViewController?
    var ingredViewController: IngredientsTableViewController?
    var dirViewController: DirectionsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Have the summary container always visible first
        summaryContainer.alpha = 1
        ingredientsContainer.alpha = 0
        directionsContainer.alpha = 0
        
        infoViewController = children.first as? InfoViewController
        let ingreNavViewController = children[1] as! UINavigationController
        ingredViewController = ingreNavViewController.viewControllers.first as? IngredientsTableViewController
        let dirNavViewController = children[2] as! UINavigationController
        dirViewController = dirNavViewController.viewControllers.first as? DirectionsTableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getImageData() -> Data? {
        // Get the recipe image from info vc if theres any
        guard let vc = infoViewController, let image = vc.imageView.image else {
            return nil
        }

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            displayMessageError(title: "Error", message: "Image size too big, please choose a lighter image.")
            return nil
        }
        return data
    }

    @IBAction func segmentValueChanged(_ sender: Any) {
        // Change the child vc visibility according to the segment selected
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

    @IBAction func onClickNextBtn(_ sender: Any) {
        guard let infoViewController = infoViewController, let ingredViewController = ingredViewController,
              let dirViewController = dirViewController else {
            return
        }
        
        // Make sure user has given at least a title for recipe to be created
        guard let title = infoViewController.titleTextField.text, title.isEmpty == false else {
            displayMessageError(title: "Empty Title", message: "Please enter a title for your new recipe.")
            return
        }
        
        // Getting the recipe info from each child vc
        recipe.title = title
        if let cookTime = infoViewController.cookTimeTextField.text {
            recipe.cookTimeInMins = Int(cookTime) ?? 0
        }
        
        if let servings = infoViewController.servingsTextField.text {
            recipe.servings = Int(servings) ?? 0
        }
        if let story = infoViewController.storyTextView.text, story.isEmpty == false {
            recipe.story = story
        }
        recipe.ingredients = ingredViewController.ingredients!
        recipe.directions = dirViewController.directions!
        let imageData = self.getImageData()
        
        // Set up OK action to save the recipe
        let okAction = UIAlertAction(title: "Save Recipe", style: .default, handler: { (action) -> Void in
             print("Ok button click...")
            var result = false
            // Check if its a recipe update or creation
            if let isEdited = self.isEdited, isEdited == true {
                result = self.databaseController?.updateRecipe(recipe: self.recipe, image: imageData) == true
            } else {
                result = self.databaseController?.addRecipe(recipe: self.recipe, image: imageData) == true
            }
            // Pop the vc if the update/creation is successful
            if result == true {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.displayMessageError(title: "Unable to save recipe", message: "Please try again.")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button click...")
        }
        
        displayMessageConfirmation(title: "Saving recipe \(title)?", message: nil, actions: [okAction, cancelAction])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfoVCSegue" {
            let destination = segue.destination as! InfoViewController
            destination.recipe = self.recipe
        } else if segue.identifier == "showIngredVCSegue" {
            let destinationNav = segue.destination as! UINavigationController
            let destination = destinationNav.viewControllers.first as! IngredientsTableViewController
            // Make a copy the ingredient array if user is updating the recipe
            if isEdited == true {
                destination.ingredients = recipe.ingredients.map{ingredient in ingredient.copy(ingredient: ingredient) as! Ingredient}
            }
        } else if segue.identifier == "showDirectionVCSegue" {
            let destinationNav = segue.destination as! UINavigationController
            let destination = destinationNav.viewControllers.first as! DirectionsTableViewController
            // Make a copy the directions array if user is updating the recipe
            if isEdited == true {
                destination.directions = recipe.directions.map{step in step.copy(step: step) as! Step}
            }
        }
    }

}
