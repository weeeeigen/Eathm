//
//  ViewController.swift
//  Earning
//
//  Created by Yusaku Eigen on 2016/06/07.
//  Copyright © 2016年 栄元優作. All rights reserved.
//

import UIKit

class CalenderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    
    @IBOutlet weak var monthImage: UIImageView!
    var firstDateMonth : NSDate!
    
    var numberOfItems: Int!
    
    var currentMonthOfDates = [NSDate]()
    
    let userDefaults = NSUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additivarl setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bg3.png")!)
        monthImage.backgroundColor = UIColor(patternImage: UIImage(named: "bg3.png")!)
        
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        
        calenderCollectionView.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 月の初日を取得
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        components.day = 1
        firstDateMonth = NSCalendar.currentCalendar().dateFromComponents(components)
        
        // 月ごとのcellの数
        let rangeOfWeeks = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.WeekOfMonth, inUnit: NSCalendarUnit.Month, forDate: firstDateMonth!)
        let numberOfWeeks = rangeOfWeeks.length
        numberOfItems = numberOfWeeks*7
        
        return numberOfItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CaledarCell", forIndexPath: indexPath)
        
        // 表記する日にちの取得
        let ordinalityOfFirstDay = NSCalendar.currentCalendar().ordinalityOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.WeekOfMonth, forDate: firstDateMonth!)
        for i in 0 ... numberOfItems {
            let dataComponents = NSDateComponents()
            dataComponents.day = i - (ordinalityOfFirstDay - 1)
            let date = NSCalendar.currentCalendar().dateByAddingComponents(dataComponents, toDate: firstDateMonth, options: NSCalendarOptions(rawValue: 0))
            currentMonthOfDates.append(date!)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        
        let label = cell.contentView.viewWithTag(3) as! UILabel
        label.text = formatter.stringFromDate(currentMonthOfDates[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        userDefaults.setObject("1", forKey: "Cal")
        let now = NSDate()
        
        let calender = NSCalendar.currentCalendar()
        
        let nowDay = calender.component(.Day, fromDate: now)
        let showDay = calender.component(.Day, fromDate: currentMonthOfDates[indexPath.row])
        
        print(nowDay)
        print(showDay)
        
//        let unitFlag: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
//        let dateComponents = calender.components(unitFlag, fromDate: now)
//        let showDate = calender.dateFromComponents(dateComponents)
        
        // 日付の差を取得
        let span = showDay - nowDay
        print(span)
        userDefaults.setObject(span, forKey: "CalValue")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    @IBAction func calBackHome(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

