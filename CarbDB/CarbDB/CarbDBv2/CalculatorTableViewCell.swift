//
//  CalculatorTableViewCell.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 2/23/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class CalculatorTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        amountField.delegate = self
        

    }
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemCarbs: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var amountField: UITextField!
    
    
    
    @objc func textFieldDoneTapped() {
        let newAmount = Double(amountField.text ?? "") ?? 0
        itemCarbAmount = round((newAmount * carbPerServing / servingSize) * 1000) / 1000
        itemCarbs.text = String(itemCarbAmount) + " carbs"
        let difference = itemCarbAmount - previousCarbAmount
        storedView?.updateTotalBy(difference: difference)
        previousCarbAmount = itemCarbAmount
        
        amountField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
    func update(with food: Food, view: CalculatorViewController) {
        titleLabel.text = food.name
        unitsLabel.text = food.servingSizeUnit
        amountField.text = String(food.servingSize)
        
        amountField.addDoneToolbar(onDone: (target: self, action: #selector(textFieldDoneTapped)))
        
        servingSizeUnits = food.servingSizeUnit
        servingSize = food.servingSize
        carbPerServing = food.carbPerServing
        itemCarbAmount = food.carbPerServing
        previousCarbAmount = itemCarbAmount
        
        itemCarbs.text = String(itemCarbAmount) + " carbs"
        
        storedView = view
    }
    
    var servingSizeUnits:String = ""
    var servingSize: Double = 0.0
    var carbPerServing: Double = 0.0
    var storedView: CalculatorViewController?
    var itemCarbAmount: Double = 0.0
    var previousCarbAmount:Double = 0.0

}
