//
//  DatabaseProtocol.swift
//  ofoods
//
//  Created by Nhung Nguyen on 3/5/2023.
//

import Foundation
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case myRecipes
    case myUser
    case users
    case sharedRecipes
    case sharedRecipeWithUsers
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onMyRecipesChange(change: DatabaseChange, recipes: [Recipe])
    func onMyUserChange(change: DatabaseChange, user: User)
    func onUsersChange(change: DatabaseChange, users: [User])
    // Listen to all the shared recipe records
    func onSharedRecipeWithUsersChange(change: DatabaseChange, sharedRecipes: [SharedRecipe])
    // Listen to the recipes shared from others
    func onSharedRecipesChange(change: DatabaseChange, recipes: [Recipe])
    // If the image takes a long from firebase to load, this listener will be invoked
    func onImageLoaded(recipe: Recipe)
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addNewUser(user: User) -> Bool
    func updateUser(user: User) -> Bool
    func updatePassword(newPass: String)
    
    func addRecipe(recipe: Recipe, image: Data?) -> Bool
    func updateRecipe(recipe: Recipe, image: Data?) -> Bool
    func deleteRecipe(recipe: Recipe)
    
    func shareRecipe(recipeId: String, userId: String) -> Bool
    func removeSharing(sharedRecipeId: String)
}
