//
//  ShareRecipeRecord.swift
//  ofoods
//
//  Created by Nhung Nguyen on 6/6/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class SharedRecipe: NSObject, Codable {
    @DocumentID var id: String?
    var userId: String?
    var recipeId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case recipeId
    }
}
