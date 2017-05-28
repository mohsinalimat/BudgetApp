//
//  ItemsViewController.swift
//  RealmBudget
//
//  Created by Lucas on 2/28/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit
import RealmSwift

class ItemsViewController: UITableViewController {

    var store = ItemsStore()
    
    override func viewDidLoad() {
        let rightButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewItem))
        self.navigationItem.rightBarButtonItem = rightButton

        store.startController()
    }
    
    func addNewItem() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let addItemView = storyBoard.instantiateViewController(withIdentifier: "AddItemView") as! AddItemViewController
        var itemKey = 0

        if (store.realmItems == nil) {
            itemKey = 0
        } else {
            itemKey = store.getNextPrimaryKey()
        }

        let item = BudgetItem()
        item.id = itemKey

        addItemView.item = item

        self.navigationController?.pushViewController(addItemView, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.tabBarController?.tabBar.isHidden)! {
            self.tabBarController?.tabBar.isHidden = false
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.realmItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.textLabel?.text = self.store.realmItems[indexPath.row].name
        cell.detailTextLabel?.text = String(self.store.realmItems[indexPath.row].value)
        if (self.store.realmItems[indexPath.row].value > 0) {
            cell.detailTextLabel?.textColor = .green
        } else {
            cell.detailTextLabel?.textColor = .red
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let addItemView = storyBoard.instantiateViewController(withIdentifier: "AddItemView") as! AddItemViewController
        addItemView.item = store.realmItems[indexPath.row]
        self.navigationController?.pushViewController(addItemView, animated: true)
    }
}
