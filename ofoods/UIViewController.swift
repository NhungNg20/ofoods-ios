//
//  UIViewController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

// Delegate used to update previous view controllers
// in a nav controller when creating a new recipe (not yet inserted in database)
protocol RecipeUpdateDelegate: AnyObject {
    func ingredientsUpdated(ingredients: [Ingredient])
    func directionsUpdated(directions: [Step])
}

extension UIViewController {
    
    func displayMessageError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayMessageConfirmation(title: String, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
