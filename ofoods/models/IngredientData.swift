//
//  IngredientData.swift
//  ofoods
//
//  Created by Nhung Nguyen on 4/5/2023.
//

import UIKit

class IngredientResultData: NSObject, Decodable {
    var ingredients: [IngredientData]?
    
    private enum CodingKeys: String, CodingKey {
        case ingredients = "results"
    }
}

class IngredientData: NSObject, Decodable {
    var id: Int
    var name: String
    var image: String?
    var units: [String]?
    
    private enum IngredientKeys: String, CodingKey {
        case id
        case name
        case image
        case units = "possibleUnits"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IngredientKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.image = try container.decode(String.self, forKey: .image)
        self.units = try container.decodeIfPresent([String].self, forKey: .units)
        
    }
}
