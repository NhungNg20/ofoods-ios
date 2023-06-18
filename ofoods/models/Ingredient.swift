//
//  Ingredient.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

class Ingredient: NSObject, Codable {
    var name: String?
    var quantity: Int?
    var unit: String?
    
    init(name: String? = nil, quantity: Int? = nil, unit: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
    
    // To do deep copy of the ingredient
    func copy(ingredient: Ingredient) -> Ingredient {
        return Ingredient(name: ingredient.name, quantity: ingredient.quantity, unit: ingredient.unit)
    }
}
