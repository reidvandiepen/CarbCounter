//
//  Food.swift
//  CarbDatabase
//
//  Created by Tammy McCullough on 1/15/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import Foundation

struct Food : Codable, Comparable {
    static func < (lhs: Food, rhs: Food) -> Bool {
        return lhs.name < rhs.name
    }
    
    var name: String
    var carbPerServing: Double
    var servingSize: Double
    var servingSizeUnit: String
    var uniqueID: UUID?
    
    init(name: String, carbPerServing: Double, servingSize: Double, servingSizeUnit: String, uniqueID: UUID?) {
        self.name = name
        self.carbPerServing = carbPerServing
        self.servingSize = servingSize
        self.servingSizeUnit = servingSizeUnit
        self.uniqueID = uniqueID
    }
    
}
