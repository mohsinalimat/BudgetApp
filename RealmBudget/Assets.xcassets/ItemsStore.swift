//
//  ItemsController.swift
//  RealmBudget
//
//  Created by Lucas on 2/28/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import RealmSwift

class ItemsStore: NSObject {
    
    var realmItems: Results<BudgetItem>!
    let realm = try! Realm()

    func startController() {
        self.realmItems = realm.objects(BudgetItem.self)
    }

    func getAllItems() -> Results<BudgetItem> {
        return self.realmItems
    }
    
    func getNextPrimaryKey() -> Int {
        if self.realmItems.count > 0 {
            return (self.realmItems.last?.id)!+1
        }
        return 0
    }
    
}
