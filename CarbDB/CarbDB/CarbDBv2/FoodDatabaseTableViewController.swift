//
//  FoodDatabaseTableViewController.swift
//  CarbDatabase
//
//  Created by Tammy McCullough on 1/15/20.
//  Copyright © 2020 Reid VanDiepen. All rights reserved.
//

import UIKit

class FoodDatabaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return foods.count
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! FoodTableViewCell
        let food = foods[indexPath.row]
        cell.textLabel?.text=food.name
        cell.detailTextLabel?.text=""
        if let carbPG = food.carbPerGrams{
            cell.detailTextLabel?.text! += "Carbs per Gram: " + String(carbPG) + "\r"
        }
        cell.detailTextLabel?.text! += "Carbs per Serving: " + String(food.carbPerServing) + "\r"
        cell.detailTextLabel?.text! += "Serving Size: " + String(food.servingSize)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
     return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            foods.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    

    

    /*
    // MARK: - Navigation   
    */
    
    var foods: [Food] = [] {
        didSet{
            
        }
    }

}
