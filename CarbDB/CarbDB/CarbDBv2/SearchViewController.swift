//
//  SearchViewController.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 2/7/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let swipe: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)
        
        searchTable.allowsSelection = true
        searchTable.dataSource = self
        searchTable.delegate = self
        searchBar.delegate = self

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let foodArchiveURL = documentsDirectory.appendingPathComponent("CarbDB").appendingPathExtension("plist")
        let selectedArchiveURL = documentsDirectory.appendingPathComponent("selectedFoods").appendingPathExtension("plist")
        let searchEditURL = documentsDirectory.appendingPathComponent("searchEditedFoods").appendingPathExtension("plist")
        let searchDeletedURL = documentsDirectory.appendingPathComponent("searchDeletedIDs").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        
        if let retrievedFoodData = try? Data(contentsOf: foodArchiveURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            foods = decodedFood
        }
        if let retrievedSelectedData = try? Data(contentsOf: selectedArchiveURL),
            let decodedSelected = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedSelectedData) {
            selectedFoods = decodedSelected
        }
        if let retrievedFoodData = try? Data(contentsOf: searchEditURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            searchEditedFoods = decodedFood
        }
        if let retrievedSelectedData = try? Data(contentsOf: searchDeletedURL),
            let decodedSelected = try? propertyListDecoder.decode(Array<UUID>.self, from: retrievedSelectedData) {
            searchDeletedIDs = decodedSelected
        }
        
        
        var deleteCounter1 = 0
        var foodCounter1 = 0
        while deleteCounter1 < searchDeletedIDs.count {
            while foodCounter1 < foods.count {
                if searchDeletedIDs[deleteCounter1] == foods[foodCounter1].uniqueID {
                    foods.remove(at: foodCounter1)
                } else { foodCounter1 += 1 }
            }
            foodCounter1 = 0
            deleteCounter1 += 1
        }
        
        var deleteCounter2 = 0
        var selectCounter1 = 0
        while deleteCounter2 < searchDeletedIDs.count {
            while selectCounter1 < selectedFoods.count {
                if searchDeletedIDs[deleteCounter2] == selectedFoods[selectCounter1].uniqueID {
                    selectedFoods.remove(at: selectCounter1)
                } else { selectCounter1 += 1 }
            }
            selectCounter1 = 0
            deleteCounter2 += 1
        }
        
        var editCounter = 0
        var addCounter = 0
        var editCopy = searchEditedFoods
        while editCounter < editCopy.count { //remove edited foods from foods list
            while addCounter < foods.count && editCounter < editCopy.count {
                if searchEditedFoods[editCounter].uniqueID == foods[addCounter].uniqueID{
                    foods.remove(at: addCounter)
                    foods.append(searchEditedFoods[editCounter])
                    editCopy.remove(at: editCounter)
                } else {
                    addCounter += 1
                }
            }
            addCounter = 0
            editCounter += 1
        }
        
        var foodCounter = 0
        var selectionCounter = 0
        while foodCounter < foods.count { //remove foods that have been selected
            while selectionCounter < selectedFoods.count && foodCounter < foods.count {
                if foods[foodCounter].uniqueID == selectedFoods[selectionCounter].uniqueID {
                    foods.remove(at: foodCounter)
                } else {
                    selectionCounter += 1
                }
            }
            selectionCounter = 0
            foodCounter += 1
        }
        
        editCounter = 0
        var selectCounter = 0
        while editCounter < searchEditedFoods.count { //replaced selected edited foods
            while selectCounter < selectedFoods.count && editCounter < searchEditedFoods.count {
                if searchEditedFoods[editCounter].uniqueID == selectedFoods[selectCounter].uniqueID{
                    selectedFoods.remove(at: selectCounter)
                    selectedFoods.append(searchEditedFoods[editCounter])
                    searchEditedFoods.remove(at: editCounter)
                } else {
                    selectCounter += 1
                }
            }
            selectCounter = 0
            editCounter += 1
        }
        searchEditedFoods.removeAll()
        searchDeletedIDs.removeAll()
        
        searchTable.reloadData()
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Selected Foods"
        } else {
            return "Foods to Add"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return selectedFoods.count
        } else if searching {
            return searchedFoods.count
        } else {
            return foods.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodTableViewCell
        if indexPath.section == 1 {
            cell.update(with: selectedFoods[indexPath.row])
        } else if searching {
            cell.update(with: searchedFoods[indexPath.row])
        } else {
            cell.update(with: foods[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTable.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 && searching {
            foods.append(selectedFoods[indexPath.row])
            searchedFoods.append(selectedFoods[indexPath.row])
            selectedFoods.remove(at: indexPath.row)
        } else if indexPath.section == 1 {
            foods.append(selectedFoods[indexPath.row])
            selectedFoods.remove(at: indexPath.row)
        } else if searching {
            selectedFoods.append(searchedFoods[indexPath.row])
            var i = 0
            while i < foods.count {
                if searchedFoods[indexPath.row] == foods[i] {
                    foods.remove(at: i)
                    i-=1
                }
                i+=1
            }
            searchedFoods.remove(at: indexPath.row)
        } else {
            selectedFoods.append(foods[indexPath.row])
            foods.remove(at: indexPath.row)
        }
        searchTable.reloadData()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    
    @IBAction func dismissVC(_ sender: Any) {
        performSegue(withIdentifier: "unwindToCalculator", sender: self)
    }
    
    var searchEditedFoods: [Food] = [] {
        didSet{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let searchEditURL = documentsDirectory.appendingPathComponent("searchEditedFoods").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(searchEditedFoods)
            try? encodedFoods?.write(to: searchEditURL, options: .noFileProtection)
        }
    }
    
    var searchDeletedIDs: [UUID] = [] {
        didSet {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let searchDeletedURL = documentsDirectory.appendingPathComponent("searchDeletedIDs").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(searchDeletedIDs)
            try? encodedFoods?.write(to: searchDeletedURL, options: .noFileProtection)
        }
    }
    
    var foods: [Food] = [] {
        didSet {
            foods.sort()
            searchTable.reloadData()
        }
    }
    var selectedFoods: [Food] = [] {
        didSet {
            selectedFoods.sort()
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let selectedArchiveURL = documentsDirectory.appendingPathComponent("selectedFoods").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedSelected = try? propertyListEncoder.encode(selectedFoods)
            try? encodedSelected?.write(to: selectedArchiveURL, options: .noFileProtection)
            searchTable.reloadData()
        }
    }
    var searchedFoods: [Food] = [] {
        didSet {
            searchedFoods.sort()
            searchTable.reloadData()
        }
    }
    var searching: Bool {
        if searchBar.text?.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedFoods.removeAll()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedFoods.removeAll()
        var i = 0
        while i < foods.count {
            if foods[i].name.lowercased().prefix(searchText.count) == searchText.lowercased() {
                searchedFoods.append(foods[i])
            }
            i+=1
        }
        searchTable.reloadData()
    }
}
