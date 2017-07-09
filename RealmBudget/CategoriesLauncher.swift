//
//  CategoriesLauncher.swift
//  RealmBudget
//
//  Created by Lucas on 3/19/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit
import RealmSwift

enum Categories: String{
    case Other = "Other"
    case Drinks = "Drinks"
    case Credit = "Credit Card"
    case Debit = "Debit Card"
    case Food = "Food"
}

class CategoriesLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var categories: Results<Category>!

    var someArray = [String]()
    var selectedItem: Category!

    let realm = try! Realm()
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        categories = realm.objects(Category.self)
        
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    var homeController: AddItemViewController?
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    let cellId = "CellId"
    let cellHeight:CGFloat = 50
    
    func showCategories() {
        
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss(_:))))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            window.addSubview(collectionView)
            let height: CGFloat = CGFloat(categories.count) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
            
        }
        
    }
    
    func handleDismiss(_ category: Category?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }) { (completed: Bool) in
            if let name = self.selectedItem?.name {
                self.homeController?.selectedCategory = self.selectedItem
                self.homeController?.labelCategory.text = name
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = self.categories[indexPath.item]
        handleDismiss(selectedItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        
        let cat = categories[indexPath.item]
        cell.category = cat
        
        return cell
    }
}
