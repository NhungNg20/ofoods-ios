//
//  Recipe.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseStorage

class Recipe: NSObject, Codable {
    @DocumentID var id: String?
    var title: String?
    var cookTimeInMins: Int?
    var servings: Int?
    var story: String?
    var ingredients: [Ingredient] = [Ingredient]()
    var directions: [Step] = [Step]()
    var authorId: String?
    var imageUrl: String?
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cookTimeInMins
        case servings
        case story
        case ingredients
        case directions
        case authorId
        case imageUrl
    }
}
