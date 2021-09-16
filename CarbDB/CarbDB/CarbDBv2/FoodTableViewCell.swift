//
//  FoodTableViewCell.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 1/20/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with food: Food) {
        titleLabel.text = food.name
        let singular = round((food.carbPerServing / food.servingSize) * 1000) / 1000
        let units = food.servingSizeUnit
        switch units {
        case "Grams":
            firstLabel.text = "Carbs per Gram: " + String(singular)
        case "Ounces":
            firstLabel.text = "Carbs per Ounce: " + String(singular)
        case "Cups":
            firstLabel.text = "Carbs per Cup: " + String(singular)
        case "Units":
            firstLabel.text = "Carbs per Unit: " + String(singular)
        default:
            firstLabel.text = "ERROR"
        }
        
        secondLabel.text = "Carbs per Serving: " + String(food.carbPerServing)
        thirdLabel.text = "Serving Size: " + String(food.servingSize) + " " + food.servingSizeUnit
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    
    
    
}
