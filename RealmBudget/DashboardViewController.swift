//
//  DashboardViewController.swift
//  RealmBudget
//
//  Created by Lucas on 2/28/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class DashboardViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var labelUserInformation: UILabel!
    @IBOutlet weak var labelGraph: UILabel!
    
    var categoriesValues = [Double]()
    var categoriesNames = [String]()
    
    let realm = try! Realm()
    
    var items = ItemsStore()
    
    var budget: Double! = 0.00
    var spent: Double! = 0.00
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var labelBudget: UILabel!
    @IBOutlet weak var labelSpent: UILabel!
    
    @IBOutlet weak var labelBudgetReadOnly: UILabel!
    @IBOutlet weak var labelSpentReadOnly: UILabel!
    
    @IBOutlet weak var labelUpcommingBill: UILabel!
    @IBOutlet weak var labelLastRegisteredItem: UILabel!

    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        items.startController()

        if (!defaults.bool(forKey: "firstTime")) {
            addCategories()
        }
        axisFormatDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if items.getAllItems().count > 0 {
            
            buildBarChart()
            calculateBudget()
            
        }
        
        labelSpent.text = "R$"+String(abs(spent))
        labelBudget.text = "R$"+String(budget)
        
        if let item = getLastRegisteredItem() {
            labelLastRegisteredItem.text = item.name
        } else {
            labelLastRegisteredItem.text = "You haven't registered an item yet!"
        }
        
        if let bill = getUpcomingBill() {
            labelUpcommingBill.text = bill.name
        } else {
            labelUpcommingBill.text = "There are no upcoming bills."
        }
        
    }

    
    func buildBarChart() {
        let categories = realm.objects(Category.self)
        
        var dataEntries: [BarChartDataEntry] = []
        var xAxis = 0
        
        categoriesValues = [Double]()
        categoriesNames = [String]()
        
        for ctgr in categories {
            let result = realm.objects(BudgetItem.self).filter("category.name = %@ AND value < 0", ctgr.name)
            
            var value = 0.00
            for item in result {
                value += abs(item.value)
            }
            
            if result.count > 0 {
                categoriesValues.append(value)
                categoriesNames.append(ctgr.name)
                
                let dataEntry = BarChartDataEntry(x: Double(xAxis), y: value)
                dataEntries.append(dataEntry)
                
                xAxis += 1
            }
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
        let chartData = BarChartData(dataSet: chartDataSet)
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        
        //Fixes weird thing where xAxis values were repeating
        xaxis.granularityEnabled = false
        xaxis.granularity = 1.0
        
        //Disable zoom (having it enabled introduces a whole bunch of bugs)
        barChartView.pinchZoomEnabled = false
        
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.drawLabelsEnabled = true
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.drawValueAboveBarEnabled = true
        barChartView.legend.enabled = false
        
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.axisMinimum = 0
        
        chartDataSet.colors = ChartColorTemplates.colorful()
        barChartView.chartDescription?.text = "Values spent by category"
        barChartView.data = chartData
        barChartView.animate(xAxisDuration: 2, yAxisDuration: 2)
    }
    
    func getUpcomingBill() -> BudgetItem? {        
        if let item = realm.objects(BudgetItem.self).filter("dateReminder > %@", Date()).sorted(byKeyPath: "id").first {
            return item
        }
        return nil
    }
    
    func getLastRegisteredItem() -> BudgetItem? {
        if let item = realm.objects(BudgetItem.self).last {
            return item
        }
        return nil
    }
    
    func calculateBudget() {
        spent = 0.00
        budget = 0.00
        
        for item in items.getAllItems() {
            if (item.value < 0) {
                spent = spent + item.value
            } else {
                budget = budget + item.value
            }
        }
    }

    func updateChartWithData() {
            var dataEntries: [BarChartDataEntry] = []
            let items = realm.objects(BudgetItem.self)
        
            for i in 0..<items.count {
                //let timeIntervalForDate: TimeInterval = visitorCounts[i].dateCreated.timeIntervalSince1970
                let dataEntry = BarChartDataEntry(x: Double(i), y: items[i].value)
                //let dataEntry = BarChartDataEntry(x: Double(i), y: Double(visitorCounts[i].value))
                dataEntries.append(dataEntry)
            }
        
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
            let chartData = BarChartData(dataSet: chartDataSet)
            let xaxis = barChartView.xAxis
            xaxis.valueFormatter = axisFormatDelegate
            barChartView.xAxis.enabled = false
            barChartView.leftAxis.drawGridLinesEnabled = false
            barChartView.rightAxis.drawGridLinesEnabled = false
            barChartView.leftAxis.drawLabelsEnabled = true
            barChartView.rightAxis.drawLabelsEnabled = true
            barChartView.drawValueAboveBarEnabled = true
            barChartView.legend.enabled = false
            chartDataSet.colors = ChartColorTemplates.colorful()
            barChartView.chartDescription?.text = "Values by category"
            barChartView.data = chartData
    }
    
    func addCategories() {
        defaults.set("true", forKey: "firstTime")
        
        try! realm.write {
            let Other = Category()
            Other.name = "Other"
            let Drinks = Category()
            Drinks.name = "Drinks"
            let Credit = Category()
            Credit.name = "Credit Card"
            let Debit = Category()
            Debit.name = "Debit Card"
            let Food = Category()
            Food.name = "Food"
            
            realm.add(Other)
            realm.add(Drinks)
            realm.add(Credit)
            realm.add(Debit)
            realm.add(Food)
        }
    }
    
}

// MARK: axisFormatDelegate
extension DashboardViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return categoriesNames[Int(value)]
    }
    
}
