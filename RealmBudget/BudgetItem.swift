//
//  BudgetItem.swift
//  RealmBudget
//
//  Created by Lucas on 2/28/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import RealmSwift

class BudgetItem: Object {
    
    dynamic var id:Int = 0
    dynamic var name:String = ""
    dynamic var value:Double = 0.00
    dynamic var category: Category? = nil
    dynamic var dateCreated = NSDate()
    dynamic var dateReminder: NSDate? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
    
}
