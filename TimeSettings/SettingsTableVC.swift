//
//  SettingsTableVC.swift
//  TimeSettings
//
//  Created by yuchen liu on 15/1/26.
//  Copyright (c) 2015年 rain. All rights reserved.
//

import UIKit

let kCellID = "cell"
let kDateCellID = "datePicker"
let kWeekCellID = "week"
let kWeekdaysCellID = "weekdays"
let kCollectionCellID = "weekdaysC"

let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
let globalTintColor = appDelegate.window!.tintColor

let kDatePickerTag = 99

let kTitleKey = "title"
let kDateKey = "date"

enum Weekday: Int {
    case MON = 0, TUE, WED, THU, FRI, SAT, SUN
    
    func description() -> String{
        switch self{
        case .MON:
            return "月"
        case .TUE:
            return "火"
        case .WED:
            return "水"
        case .THU:
            return "木"
        case .FRI:
            return "金"
        case .SAT:
            return "土"
        case .SUN:
            return "日"
        }
    }
}

struct SettingItem {
    
    var title: String
    
    var date: NSDate

}

class SettingsTableVC: UITableViewController {
    
    var kDataEndRow: Int{
        return dataArray.count
    }
    
    var dataArray: [SettingItem]!
    
    var dateCellRowHeight: CGFloat = 216
    
    var datePickerIndexPath: NSIndexPath?
    
    var weekdaysCellIndexPath: NSIndexPath?
    
    var selectedIndexPaths: [NSIndexPath]!
    
    var weekDaysData: [Weekday]!
    
    let allWeekdays: [Weekday] = [.MON, .TUE, .WED, .THU, .FRI, .SAT, .SUN]
    
    let dateFormatter = NSDateFormatter()
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.dateFormat = "HH:mm"
        self.dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_GB")
        
        var date = self.dateFormatter.dateFromString("08:00")
        
        println("why -> \(date)")
        
        self.dataArray = [SettingItem(title: "起床", date: self.dateFormatter.dateFromString("08:00")!),
                          SettingItem(title: "出社", date: self.dateFormatter.dateFromString("09:30")!),
                          SettingItem(title: "昼休み", date: self.dateFormatter.dateFromString("12:10")!),
                          SettingItem(title: "退社", date: self.dateFormatter.dateFromString("18:30")!),
                          SettingItem(title: "就寝", date: self.dateFormatter.dateFromString("23:30")!)]
        
        
        self.weekDaysData = [.SAT, .SUN]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("localChanged:"), name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    func localChanged(notification: NSNotification){
        //user change local settings, update date formatter
        self.tableView.reloadData()
    }

}

//MARK: utility method
extension SettingsTableVC{
    @IBAction func dateAciton(sender: AnyObject) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.hasInlineDatePicker(){
            targetedCellIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row - 1, inSection: 0)
        }
        
        if targetedCellIndexPath != nil {
            let cell = self.tableView.cellForRowAtIndexPath(targetedCellIndexPath!)
            
            let datePicker = sender as UIDatePicker
            
            self.dataArray[targetedCellIndexPath!.row].date = datePicker.date
            
            cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(self.dataArray[targetedCellIndexPath!.row].date)
        }
        
    }
    
    func hasInlineDatePicker() -> Bool{
        return self.datePickerIndexPath != nil
    }
    
    func hasInlineWeekdays() -> Bool{
        return self.weekdaysCellIndexPath != nil
    }
    
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool{
        return self.hasInlineDatePicker() && self.datePickerIndexPath!.row == indexPath.row
    }
    
    func indexPathHasWeekdays(indexPath: NSIndexPath) -> Bool{
        return self.hasInlineWeekdays() && self.weekdaysCellIndexPath!.row == indexPath.row
    }
    
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool{
        
        if self.hasInlineDatePicker(){
            
            let pickerIndex = self.datePickerIndexPath!.row
            
            if pickerIndex == kDataEndRow {
                if indexPath.row < kDataEndRow{
                    return true
                }
            }else{
                if indexPath.row != pickerIndex && indexPath.row != kDataEndRow + 1 {
                    return true
                }
            }
            
        }else{
        
            if indexPath.row >= 0 && indexPath.row < kDataEndRow {
                return true
            }
        
        }
       
    
        return false
    }
    
    func updateDatePicker(){
        
        if self.datePickerIndexPath != nil {
            
            let datePickerCell = self.tableView.cellForRowAtIndexPath(self.datePickerIndexPath!)
            
            let datePickerBuffer = datePickerCell?.viewWithTag(kDatePickerTag)
            
            if let datePicker = datePickerBuffer as? UIDatePicker{
                let itemData = self.dataArray[self.datePickerIndexPath!.row - 1]
                
                datePicker.setDate(itemData.date, animated: false)
            }
            
        }
        
    }

    
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath){
        self.tableView.beginUpdates()
        
        let targetIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
        
        let indexPaths = [targetIndexPath]
        
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        
        self.tableView.endUpdates()
    }
    
    func toggleWeekdaysForSelectedIndexPath(indexPath: NSIndexPath){
        self.tableView.beginUpdates()
        
        let targetIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
        
        let indexPaths = [targetIndexPath]
        
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        
        self.tableView.endUpdates()
    }
    
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath){
        
        self.tableView.beginUpdates()
        
        var sameCellClicked: Bool = false
        
        var before: Bool = false
        
        //already has weekdays
        if self.hasInlineWeekdays(){
            self.tableView.deleteRowsAtIndexPaths([self.weekdaysCellIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            println("remove weekdaysIndexPath -> \(self.weekdaysCellIndexPath!.row)")
            
            self.weekdaysCellIndexPath = nil
            
        }
        
        if self.hasInlineDatePicker(){
            before = self.datePickerIndexPath!.row < indexPath.row
            
            sameCellClicked = (self.datePickerIndexPath!.row - 1 == indexPath.row)
            
            println("indexPath -> \(indexPath.row)")
        }
        
        
        //already has picker
        if self.hasInlineDatePicker(){

            self.tableView.deleteRowsAtIndexPaths([self.datePickerIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            println("remove datePickerIndexPath -> \(self.datePickerIndexPath!.row)")
        
            self.datePickerIndexPath = nil
    
        }
        
        
        if !sameCellClicked {
            
            let rowToReveal: Int = (before ? indexPath.row - 1 : indexPath.row)
            
            let indexPathToReveal: NSIndexPath = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            self.datePickerIndexPath = NSIndexPath(forRow: rowToReveal + 1, inSection: 0)
            
            self.toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.endUpdates()
        
        self.updateDatePicker()
        
    }
    
    
    func displayWeekdaysForRowAtIndexPath(indexPath: NSIndexPath){
        
        self.tableView.beginUpdates()
        
        var realIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        
        //already has picker
        if self.hasInlineDatePicker(){
            
            self.tableView.deleteRowsAtIndexPaths([self.datePickerIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            println("remove datePickerIndexPath -> \(self.datePickerIndexPath!.row)")
            
            self.datePickerIndexPath = nil
            
            realIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
        }
        
        
        if self.hasInlineWeekdays(){
            self.tableView.deleteRowsAtIndexPaths([self.weekdaysCellIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            println("remove weekdaysIndexPath -> \(self.weekdaysCellIndexPath!.row)")
            
            self.weekdaysCellIndexPath = nil

        }else{
            
            self.weekdaysCellIndexPath = NSIndexPath(forRow: realIndexPath.row + 1, inSection: 0)
            
            self.toggleWeekdaysForSelectedIndexPath(realIndexPath)
        }
        
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.endUpdates()

    }
}

//MARK: UITableViewDataSource
extension SettingsTableVC: UITableViewDataSource{

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.hasInlineDatePicker() || self.hasInlineWeekdays() {
            return self.dataArray.count + 1 + 1
        }
        
        return self.dataArray.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellID = kWeekCellID
        
        if self.indexPathHasPicker(indexPath){
            cellID = kDateCellID
        }else if self.indexPathHasDate(indexPath){
            cellID = kCellID
        }else if self.indexPathHasWeekdays(indexPath){
            cellID = kWeekdaysCellID
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID) as UITableViewCell

        cell.detailTextLabel?.textColor = globalTintColor
        
        println("cellForRowAtIndexPath -> \(indexPath.row), cellID -> \(cellID)")
        
        
        if cellID == kCellID{
            
            var forDataSourceIndex = indexPath.row
            
            if self.hasInlineDatePicker(){
                //has one picker, so data source index have to change
                if self.datePickerIndexPath?.row < indexPath.row{
                    forDataSourceIndex = indexPath.row - 1
                }
            }
            
            cell.textLabel?.text = self.dataArray[forDataSourceIndex].title
            
            println("cell.textLabel?.text -> \(cell.textLabel?.text)")
            
            let date = self.dataArray[forDataSourceIndex].date
            
            cell.detailTextLabel?.text = self.dateFormatter.stringFromDate(date)
            
        }else if cellID == kWeekCellID{
            cell.textLabel?.text = "休日"
            
            weekDaysData.sort{$0.rawValue < $1.rawValue}
            
            cell.detailTextLabel?.text =  weekDaysData.reduce(""){
                (detailString: String, weekday: Weekday) in
                return countElements(detailString) == 0 ? "\(weekday.description())" : "\(detailString),\(weekday.description())"
            }
            
            println("cell.detailTextLabel -> \(cell.detailTextLabel?.text)")
        }
        
        return cell
    }
    
    
    func updateWeekCell(){
        let visibeCells = self.tableView.visibleCells() as [UITableViewCell]
        
        let weekCellArray = visibeCells.filter{
            $0.reuseIdentifier == kWeekCellID
        }
        
        let indexPaths = weekCellArray.map{self.tableView.indexPathForCell($0)!}
        
        if indexPaths.count > 0 {
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            self.tableView.endUpdates()
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:
        NSIndexPath) -> CGFloat {

            return self.indexPathHasPicker(indexPath) ? self.dateCellRowHeight : 44
    }
}

//MARK: UITableViewDelegate
extension SettingsTableVC: UITableViewDelegate{
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.reuseIdentifier == kCellID{
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
        }else if cell?.reuseIdentifier == kWeekCellID{
            self.displayWeekdaysForRowAtIndexPath(indexPath)
        }
        else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

//MARK: UICollectionViewDataSource
extension SettingsTableVC: UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allWeekdays.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if !collectionView.allowsMultipleSelection{
            collectionView.allowsMultipleSelection = true
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionCellID, forIndexPath:indexPath) as UICollectionViewCell
        
        cell.layer.cornerRadius = 5.0
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        //self weekDay
        var cellWeekDay = allWeekdays[indexPath.row]
        
        if let label = cell.viewWithTag(100) as? UILabel{
            label.text = cellWeekDay.description()
            
            for objc in weekDaysData{
                if cellWeekDay == objc{
                    selectedStyleForCell(cell)
                }
            }

        }
        
        
        return cell as UICollectionViewCell
        
    }
    
    
    func selectedStyleForCell(cell: UICollectionViewCell){
        cell.layer.borderColor = globalTintColor.CGColor
        if let label = cell.viewWithTag(100) as? UILabel{
            label.textColor = globalTintColor
        }
    }
    
    func unselectedStyleForCell(cell: UICollectionViewCell){
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        if let label = cell.viewWithTag(100) as? UILabel{
            label.textColor = UIColor.lightGrayColor()
        }
    }

}

//MARK: UICollectionViewDelegate
extension SettingsTableVC: UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as UICollectionViewCell!
        let selectWeekday = allWeekdays[indexPath.row]
        
        //check for already selected
        if contains(weekDaysData, selectWeekday){
            
            let containedIndexPath = NSIndexPath(forRow: selectWeekday.rawValue, inSection: 0)
            
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
           
            self.collectionView(collectionView, didDeselectItemAtIndexPath: containedIndexPath)
            
            return
        }
        
        println("didSelectItemAtIndexPath -> \(indexPath.row)")
        
        selectedStyleForCell(cell)
        
        weekDaysData.append(selectWeekday)
        
        //update view
        updateWeekCell()
        
        println("select weekDaysData -> \(weekDaysData.count), \(weekDaysData),\(selectWeekday.description())")
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        println("didDeselectItemAtIndexPath -> \(indexPath.row)")
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as UICollectionViewCell!
        
        unselectedStyleForCell(cell)
        
        let unselectWeekday = allWeekdays[indexPath.row]
        
        weekDaysData = weekDaysData.filter{ $0 != unselectWeekday}
        
        //update view
        updateWeekCell()
        
        println("unselect weekDaysData -> \(weekDaysData.count), \(weekDaysData),\(unselectWeekday.description())")
    }
}