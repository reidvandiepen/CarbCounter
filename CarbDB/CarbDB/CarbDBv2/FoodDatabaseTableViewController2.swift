//
//  FoodDatabaseTableViewController.swift
//  CarbDatabase
//
//  Created by Tammy McCullough on 1/15/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit


class FoodDatabaseTableViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("CarbDB").appendingPathExtension("plist")
        let editedURL = documentsDirectory.appendingPathComponent("editedFoods").appendingPathExtension("plist")
        let searchEditURL = documentsDirectory.appendingPathComponent("searchEditedFoods").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        
        if let retrievedFoodData = try? Data(contentsOf: archiveURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            foods = decodedFood
        }
        if let retrievedFoodData = try? Data(contentsOf: editedURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            editedFoods = decodedFood
        }
        if let retrievedFoodData = try? Data(contentsOf: searchEditURL),
            let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
            searchEditedFoods = decodedFood
        }
        
        tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    var searchedFoods: [Food] = [] {
        didSet {
            searchedFoods.sort()
            tableView.reloadData()
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
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        editedFoods.removeAll()
        deletedFoodsID.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedFoods.count
        } else {
            return foods.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodTableViewCell
        if searching {
            cell.update(with: searchedFoods[indexPath.row])
        } else {
            cell.update(with: foods[indexPath.row])
        }
        return cell
    }
    
    

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedFoodsID.append(foods[indexPath.row].uniqueID!)
            searchDeletedIDs.append(foods[indexPath.row].uniqueID!)
            foods.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
     editingStyleForRowAt indexPath: IndexPath) ->
     UITableViewCell.EditingStyle {
     return .delete
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFood" {
            let indexPath = tableView.indexPathForSelectedRow!
            let food = foods[indexPath.row]
            let navController = segue.destination as! UINavigationController
            let addFoodTableViewController = navController.topViewController as! AddFoodTableViewController
            addFoodTableViewController.food = food
            addFoodTableViewController.edit = true
        }
    }
    
    @IBAction func unwindToFoodDatabaseView(segue: UIStoryboardSegue) {
            guard segue.identifier == "saveUnwind",
                    let sourceViewController = segue.source as? AddFoodTableViewController,
                let food = sourceViewController.food else { return }
        
                if let selectedIndexPath = tableView.indexPathForSelectedRow
                {
                    foods[selectedIndexPath.row] = food
                    tableView.reloadRows(at: [selectedIndexPath],
                    with: .none)
                } else {
                    let newIndexPath = IndexPath(row: foods.count,section: 0)
                    foods.append(food)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
        if sourceViewController.edit {
            var i = 0
            while i < editedFoods.count {
                if editedFoods[i].uniqueID == food.uniqueID {
                    editedFoods.remove(at: i)
                } else {
                    i+=1
                }
            }
            editedFoods.append(food)
            
            var j = 0
            while j < searchEditedFoods.count {
                if searchEditedFoods[j].uniqueID == food.uniqueID {
                    searchEditedFoods.remove(at: j)
                } else {
                    j+=1
                }
            }
            searchEditedFoods.append(food)
        }
        sourceViewController.edit = false
        
        tableView.reloadData()
    }
    
    
    var deletedFoodsID: [UUID] = [] {
        didSet{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let deletedURL = documentsDirectory.appendingPathComponent("deletedIDs").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(deletedFoodsID)
            try? encodedFoods?.write(to: deletedURL, options: .noFileProtection)
            
            var i = 0
            var j = 0
            while i < deletedFoodsID.count {
                while i < deletedFoodsID.count && j < editedFoods.count{
                    if deletedFoodsID[i] == editedFoods[j].uniqueID {
                        editedFoods.remove(at: j)
                    } else {
                        j+=1
                    }
                }
                j = 0
                i+=1
            }
        }
    }
    
    var searchDeletedIDs: [UUID] = [] {
        didSet{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let searchDeletedURL = documentsDirectory.appendingPathComponent("searchDeletedIDs").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(searchDeletedIDs)
            try? encodedFoods?.write(to: searchDeletedURL, options: .noFileProtection)
            
            var i = 0
            var j = 0
            while i < searchDeletedIDs.count {
                while i < searchDeletedIDs.count && j < searchEditedFoods.count{
                    if searchDeletedIDs[i] == searchEditedFoods[j].uniqueID {
                        searchEditedFoods.remove(at: j)
                    } else {
                        j+=1
                    }
                }
                j = 0
                i+=1
            }
        }
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
    
    var editedFoods: [Food] = [] {
        didSet{
            editedFoods.sort()
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let editedURL = documentsDirectory.appendingPathComponent("editedFoods").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(editedFoods)
            try? encodedFoods?.write(to: editedURL, options: .noFileProtection)
        }
    }
    
    var foods: [Food] = [] {
        didSet{
            foods.sort()
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let archiveURL = documentsDirectory.appendingPathComponent("CarbDB").appendingPathExtension("plist")
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedFoods = try? propertyListEncoder.encode(foods)
            try? encodedFoods?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    

}
