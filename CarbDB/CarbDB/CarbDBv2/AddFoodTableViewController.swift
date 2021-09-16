//
//  AddFoodTableViewController.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 1/23/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class AddFoodTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = pickerData[row]
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.servingUnitPickerView.delegate=self
        self.servingUnitPickerView.dataSource=self
        
        if let food = food {
            nameTextField.text = food.name
            carbsPerServingTextFields.text = String(food.carbPerServing)
            servingSizeTextField.text = String(food.servingSize)
            pickerSelection = food.servingSizeUnit
            ID = food.uniqueID ?? UUID()
            var counter = 0
            for i in pickerData {
                if pickerSelection == i {
                    servingUnitPickerView.selectRow(counter, inComponent: 0, animated: false)
                }
                counter += 1
            }
        }
        
        updateSaveButtonState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:
    Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        let name = nameTextField.text ?? ""
        let carbsPerServing = carbsPerServingTextFields.text ?? ""
        let servingSize = servingSizeTextField.text ?? ""
        food = Food(name: name, carbPerServing: Double(carbsPerServing) ?? 0, servingSize: Double(servingSize) ?? 0, servingSizeUnit: pickerSelection, uniqueID: ID)
    }
    
    var food : Food?
    var pickerData: [String] = ["Ounces", "Grams", "Cups", "Units"]
    var pickerSelection: String = "Ounces"
    var edit: Bool = false
    var ID: UUID = UUID()

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var carbsPerServingTextFields: UITextField!
    @IBOutlet weak var servingSizeTextField: UITextField!
    @IBOutlet weak var servingUnitPickerView: UIPickerView!
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    func updateSaveButtonState(){
        let nameText = nameTextField.text ?? ""
        let cpsText = carbsPerServingTextFields.text ?? ""
        let servingSizeText = servingSizeTextField.text ?? ""
            saveButton.isEnabled = !nameText.isEmpty && !cpsText.isEmpty && !servingSizeText.isEmpty
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField){
        updateSaveButtonState()
    }
}
