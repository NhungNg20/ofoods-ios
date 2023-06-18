//
//  Direction.swift
//  ofoods
//
//  Created by Nhung Nguyen on 28/4/2023.
//

import UIKit

class Step: NSObject, Codable {
    var detail: String?
    
    init(detail: String? = nil) {
        self.detail = detail
    }
    
    func copy(step: Step) -> Step {
        return Step(detail: step.detail)
    }
}
