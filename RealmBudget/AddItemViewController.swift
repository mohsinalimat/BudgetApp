//
// Created by Lucas on 2/28/17.
// Copyright (c) 2017 Lucas. All rights reserved.
//

import UIKit
import RealmSwift

class AddItemViewController: UIViewController {

    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldValue: UITextField!
    @IBOutlet weak var labelDateCreated: UILabel!
    @IBOutlet weak var categoryPicker: UIView!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var itemDatePicker: UIDatePicker!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    lazy var settingsLauncher: CategoriesLauncher = {
        let launcher = CategoriesLauncher()
        launcher.selectedItem = self.item.category
        launcher.homeController = self
        return launcher
    }()
    
    let realm = try! Realm()
    
    var selectedDate: Date? = nil
    var item: BudgetItem!
    var categories: Results<Category>!

    var selectedCategory: Category?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.categories = realm.objects(Category.self)

        self.tabBarController?.tabBar.isHidden = true

        loadItemView()

        itemDatePicker.minimumDate = Date()
        
        let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = saveBarButton
        self.categoryPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCategoriesPicker)))
    }

    func loadItemView() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        
        labelDateCreated.text = String(formatter.string(from: item.dateCreated as Date))
        selectedCategory = categories?[0]
        itemDatePicker.isEnabled = false

        if item.name != "" {
            fieldName.text = item.name
            fieldValue.text = String(item.value)

            if (item.dateReminder != nil){
                alarmSwitch.isOn = true
                itemDatePicker.isEnabled = true
                itemDatePicker.date = item.dateReminder! as Date
            }
            
            var count = 0
            for cat in categories! {
                if (cat.name == item.category?.name) {
                    labelCategory.text = cat.name
                    selectedCategory = categories?[count]
                }
                count = count + 1
            }
        }
    }

    func saveItem() {
        if (validateForm()) {
            try! realm.write {
                item.name = fieldName.text!
                item.value = Double(fieldValue.text!)!
                item.category = selectedCategory
                
                if alarmSwitch.isOn {
                    item.dateReminder = selectedDate as NSDate?
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotification(at: selectedDate!, id: item.id, item: item)
                } else {                    
                    item.dateReminder = nil
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.removePendingNotification(id: item.id)
                }
                
                realm.add(item, update: true)
            }
        }

        _ = self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func alarmPicked(_ sender: UISwitch) {
        if sender.isOn {
            itemDatePicker.isEnabled = true
        } else {
            itemDatePicker.isEnabled = false
            selectedDate = nil
        }
    }
    
    @IBAction func datePicked(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    func showCategoriesPicker() {
        settingsLauncher.showCategories()
    }
    
    func validateForm() -> Bool {
        if (fieldName.text == "" || fieldValue.text == "") {
            return false
        }
        return true;
    }
    
    @IBAction func btnDelete(_ sender: Any) {
        try! realm.write {
            realm.delete(item)
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
