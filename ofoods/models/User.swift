//
//  User.swift
//  ofoods
//
//  Created by Nhung Nguyen on 12/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class User: NSObject, Codable {
    @DocumentID var id: String?
    var userName: String?
    var email: String?
    var recipes: [DocumentReference]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case email
        case recipes
    }
    
    init(id: String? = nil, userName: String? = nil, email: String? = nil, recipes: [DocumentReference]? = nil) {
        self.id = id
        self.userName = userName
        self.email = email
        self.recipes = recipes
    }
}
