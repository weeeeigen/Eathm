//
//  HomeViewController.swift
//  Earning
//
//  Created by Yusaku Eigen on 2016/06/07.
//  Copyright © 2016年 栄元優作. All rights reserved.
//

import UIKit
import SCLAlertView
import ZFRippleButton

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var dateImage: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayLabel2: UILabel!
    
    @IBOutlet weak var weekLabel: UILabel!
    
    @IBOutlet weak var weekLabel2: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let userDefaults = NSUserDefaults()
    
    var dayCount: Double = 0
    
    var images: [NSData] = []
    var types: [String] = []
    var times:[String] = []
    
    
    let days = [ "十", "一", "二", "三", "四", "五", "六", "七", "八", "九" ]
    let days2 = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth",
                 "eleven", "twelve", "thirteen", "fourteen", "fifteen", "thirteen", "seventeen", "eighteen", "nineteen", "twenty",
                 "twenty-first", "twenty-second", "twenty-third", "twenty-fourth","twenty-fifth", "twenty-sixth", "twenty-seventh", "twenty-eighth", "twenty-ninth", "thirtieth",
                 "thirty-one"]
    
    
    let weeks = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    let weeks2 = ["日", "月", "火", "水", "木", "金", "土"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 2000)
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        dateImage.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        
        userNameLabel.text = userDefaults.objectForKey("UserName")as? String

        userDefaults.setObject("0", forKey: "Cal")
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        dayCount = 0
        
        if userDefaults.objectForKey("Cal") as! String == "0" {
            getImage(0)
        }else{
            getImage(userDefaults.objectForKey("CalValue") as! Double)
            userDefaults.setObject("0", forKey: "Cal")
        }
        
    }
    
    
    @IBAction func showBefore(sender: AnyObject) {
        getImage(-1)
    }
    
    @IBAction func showAfter(sender: AnyObject) {
        getImage(1)
    }
    
    func getImage(i: Double) {
        
        dayCount += i
        
        let now = NSDate()
        let showDate = NSDate(timeInterval: dayCount*24*60*60, sinceDate: now)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.stringFromDate(showDate)
        
        
        // 画像データを持ってくる
        let url = NSURL(string: "https://life-cloud.ht.sfc.keio.ac.jp/~eigen/EatWarning/geturl.php")!
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let request = NSMutableURLRequest(URL: url)
        let name = userDefaults.objectForKey("UserName")!
        request.HTTPMethod = "POST"
        request.HTTPBody = "UserName=\(name)&Date=\(date)".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) in
            if error == nil{
                let httpResponse = response as? NSHTTPURLResponse
                if(httpResponse?.statusCode == 200){
                    let result = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    let data = result?.dataUsingEncoding(NSUTF8StringEncoding)
                    let json = JSON(data: data!)
                    
                    // データがある日だけ
                    if json[0] != [] {
                        print(json)
                        self.images = []
                        self.types = []
                        self.times = []
                        dispatch_async(dispatch_get_main_queue(), {
                            for i in 0..<json[0].count{
                                do{
                                    let imageData = try NSData(contentsOfURL: NSURL(string: json[0][i].string!)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                                    self.images.append(imageData)
                                    
                                    self.types.append(json[1][i].string!)
                                    self.times.append(json[2][i].string!)
                                }catch{
                                    print("NotFoundImage")
                                }
                                self.table.reloadData()
                                
                                let nowDate = NSDate(timeInterval: self.dayCount*24*60*60, sinceDate: now)
                                
                                // 日を表示
                                formatter.dateFormat = "dd"
                                let day: Int = Int( formatter.stringFromDate(nowDate) )!
                                
                                self.dayLabel.text = String(day)
                                self.dayLabel2.text = self.days2[day - 1]
                                
                                
                                // 曜日を表示
                                let comp = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: nowDate)
                                let weekIndex = comp.weekday
                                self.weekLabel.text = self.weeks[weekIndex - 1]
                                self.weekLabel2.text = self.weeks2[weekIndex - 1]
                            }
                        })
                    }else{
                        self.dayCount -= i
                        let nowDate = NSDate(timeInterval: self.dayCount*24*60*60, sinceDate: now)
                        print(nowDate)
                        
                        // 日を表示
                        formatter.dateFormat = "dd"
                        let day: Int = Int( formatter.stringFromDate(nowDate) )!
                        
                        self.dayLabel.text = String(day)
                        self.dayLabel2.text = self.days2[day - 1]
                        
                        // 曜日を表示
                        let comp = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: nowDate)
                        let weekIndex = comp.weekday
                        self.weekLabel.text = self.weeks[weekIndex - 1]
                        self.weekLabel2.text = self.weeks2[weekIndex - 1]
                        print("Limit")
                    }
                }else{
                    print(httpResponse)
                }
            }else{
                print("postできなかったよ")
            }
        })
        task.resume()
        
        
    }
    
    
    
    
    // Table Viewのセルの数を指定
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    // 各セルの要素を設定する
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCellWithIdentifier("eatLogCell", forIndexPath: indexPath)

        let img = UIImage(data: images[indexPath.row])
            
        let imageView = table.viewWithTag(1) as! UIImageView
        imageView.image = img
        
        let typeLabel = table.viewWithTag(2) as! UILabel
        typeLabel.text = types[indexPath.row]
        
        let dateLabel = table.viewWithTag(3)as! UILabel
        dateLabel.text = times[indexPath.row]
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
