//
//  SearchableDatabaseTableViewController.swift
//  CarbDBv2
//
//  Created by Tammy McCullough on 2/6/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class SearchableDatabaseTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let archiveURL = documentsDirectory.appendingPathComponent("CarbDB").appendingPathExtension("plist")
        
            let propertyListDecoder = PropertyListDecoder()
            if let retrievedFoodData = try? Data(contentsOf: archiveURL),
                let decodedFood = try? propertyListDecoder.decode(Array<Food>.self, from: retrievedFoodData) {
                foods = decodedFood
            }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodTableViewCell
        if searching {
            cell.update(with: searchedFoods[indexPath.row])
        } else {
            cell.update(with: foods[indexPath.row])
        }
        return cell
    }
    


    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    var foods: [Food] = []
    
    var searchedFoods: [Food] = []
    var searching: Bool = false
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        for food in foods {
            if food.name.prefix(searchText.count) == searchText {
                searchedFoods.append(food)
            }
        }
        
    }

}
