//
//  CalculatorTableViewController.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 2/6/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let selectedArchiveURL = documentsDirectory.appendingPathComponent("selectedFoods").appendingPathExtension("plist")
        let editedURL = documentsDirectory.appendingPathComponent("editedFoods").appendingPathExtension("plist")
        let deletedURL = documentsDirectory.appendingPathComponent("deletedIDs").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedSelectedData = try? Data(contentsOf: selectedArchiveURL),
            let decodedSelected = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedSelectedData) {
            selectedFoods = decodedSelected
        }
        if let retrievedFoodData = try? Data(contentsOf: editedURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            editedFoods = decodedFood
        }
        if let retrievedSelectedData = try? Data(contentsOf: deletedURL),
            let decodedSelected = try? propertyListDecoder.decode(Array<UUID>.self, from: retrievedSelectedData) {
            deletedIDs = decodedSelected
        }
        
        calculatorTable.delegate = self
        calculatorTable.dataSource = self
        
        calculatorTable.allowsSelection = false
        
        print(editedFoods, "before check")
        
        if editedFoods.count > 0 {
            var i = 0
            var j = 0
            while i < editedFoods.count {
                while j < selectedFoods.count && i < editedFoods.count {
                    if editedFoods[i].uniqueID == selectedFoods[j].uniqueID {
                        selectedFoods.remove(at: j)
                        selectedFoods.append(editedFoods[i])
                        editedFoods.remove(at: i)
                    } else {
                        j+=1
                    }
                }
                j = 0
                i+=1
            }
            i = 0
        }
        
        print(editedFoods, "after check")
        
        if deletedIDs.count > 0 {
            var i = 0
            var j = 0
            while i < deletedIDs.count {
                while j < selectedFoods.count {
                    if deletedIDs[i] == selectedFoods[j].uniqueID {
                        selectedFoods.remove(at: j)
                    } else {
                        j += 1
                    }
                }
                j = 0
                i += 1
            }
        }
        
        selectedFoods.sort()
        
        totalCarbs = 0
        calcInitialTotal()
        
        calculatorTable.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let newFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let insets = UIEdgeInsets( top: 0, left: 0, bottom: newFrame.height, right: 0)
            calculatorTable.contentInset = insets
            calculatorTable.scrollIndicatorInsets = insets
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        calculatorTable.contentInset = insets
        calculatorTable.scrollIndicatorInsets = insets
    }
    
    
    

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFoods.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calcCell", for: indexPath) as! CalculatorTableViewCell
        cell.update(with: selectedFoods[indexPath.row], view: self)
        return cell
    }
    
    var selectedFoods: [Food] = []
    var totalCarbs: Double = 0
    var editedFoods: [Food] = []
    var deletedIDs: [UUID] = []

    @IBOutlet weak var totalCarbLabel: UILabel!
    @IBOutlet weak var calculatorTable: UITableView!
    
    func updateTotalBy(difference: Double) {
       totalCarbs += difference
       totalCarbLabel.text = "Total Carbs: " + String(totalCarbs) + " carbs"
    }
    
    func calcInitialTotal() {
        for food in selectedFoods {
            totalCarbs += food.carbPerServing
        }
        totalCarbLabel.text = "Total Carbs: " + String(totalCarbs) + " carbs"
    }
    
    // MARK: - Navigation

    @IBAction func unwindToCalculator(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindToCalculator" else { return }
        
        viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
