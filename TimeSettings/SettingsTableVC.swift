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

let kDatePickerTag = 99

let kTitleKey = "title"
let kDateKey = "date"

struct SettingItem {
    
    var title: String
    
    var date: NSDate
}

class SettingsTableVC: UITableViewController {
    
    var kDataEndRow: Int{
        return dataArray.count
    }
    
    var dataArray = [SettingItem]()
    
    var dateCellRowHeight: CGFloat = 0
    
    var datePickerIndexPath: NSIndexPath?
    
    let dateFormatter = NSDateFormatter()
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataArray = [SettingItem(title: "起床", date: NSDate()),
                     SettingItem(title: "出社", date: NSDate()),
                     SettingItem(title: "昼休み", date: NSDate()),
                     SettingItem(title: "退社", date: NSDate()),
                     SettingItem(title: "就寝", date: NSDate())]
        
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
     
        let dateCell = self.tableView.dequeueReusableCellWithIdentifier(kDateCellID) as UITableViewCell
        
        self.dateCellRowHeight = 216
        
        println("dateCell -> \(dateCell)")
        
        println("dateCellRowHeight -> \(self.dateCellRowHeight)")
        
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
        var targetedCellIndexPath: NSIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row - 1, inSection: 0)
        
        
        let cell = self.tableView.cellForRowAtIndexPath(targetedCellIndexPath)
        
        let datePicker = sender as UIDatePicker
        
        self.dataArray[targetedCellIndexPath.row].date = datePicker.date
        
        cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(self.dataArray[targetedCellIndexPath.row].date)
        
    }
    
    func hasInlineDatePicker() -> Bool{
        return self.datePickerIndexPath != nil
    }
    
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool{
        return self.hasInlineDatePicker() && self.datePickerIndexPath!.row == indexPath.row
    }
    
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool{
        
        if (0 <= indexPath.row && indexPath.row < kDataEndRow) ||  (self.hasInlineDatePicker() && indexPath.row == kDataEndRow + 1){
            return true
        }
    
        return false
    }
    
    func updateDatePicker(){
        
        if self.datePickerIndexPath != nil {
            
            let datePickerCell = self.tableView.cellForRowAtIndexPath(self.datePickerIndexPath!)
            
            let datePickerBuffer = datePickerCell?.viewWithTag(kDatePickerTag)
            
            if let datePicker = datePickerBuffer as? UIDatePicker{
                let itemData = self.dataArray[self.datePickerIndexPath!.row - 1]
                
                datePicker.setDate(itemData.date, animated: true)
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
    
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath){
        
        self.tableView.beginUpdates()
        
        var sameCellClicked: Bool = false
        
        var before: Bool = false
        
        if self.hasInlineDatePicker(){
            before = self.datePickerIndexPath!.row < indexPath.row
            
            sameCellClicked = (self.datePickerIndexPath!.row - 1 == indexPath.row)
            
            println("indexPath -> \(indexPath.row)")
        }
        
        //already has picker
        if self.hasInlineDatePicker(){

            self.tableView.deleteRowsAtIndexPaths([self.datePickerIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            println("datePickerIndexPath -> \(self.datePickerIndexPath!.row)")
        
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
}


extension SettingsTableVC: UITableViewDataSource{

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.hasInlineDatePicker(){
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
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID) as UITableViewCell
        
        println("cellForRowAtIndexPath -> \(indexPath.row)")
        
        if cellID == kCellID{
            
            cell.textLabel?.text = self.dataArray[indexPath.row].title
            
            let date = self.dataArray[indexPath.row].date
            
            cell.detailTextLabel?.text = self.dateFormatter.stringFromDate(date)
            
        }else if cellID == kWeekCellID{
            cell.textLabel?.text = "休日"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:
        NSIndexPath) -> CGFloat {
        
            println("dateCellRowHeight -> \(self.dateCellRowHeight)")
            
            return self.indexPathHasPicker(indexPath) ? self.dateCellRowHeight : self.tableView.rowHeight
    }
}

extension SettingsTableVC: UITableViewDelegate{
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.reuseIdentifier == kCellID{
            self.displayInlineDatePickerForRowAtIndexPath(indexPath)
        }else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}