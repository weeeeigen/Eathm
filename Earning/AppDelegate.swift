//
//  AppDelegate.swift
//  Earning
//
//  Created by Yusaku Eigen on 2016/06/07.
//  Copyright © 2016年 栄元優作. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // 初回起動時に呼ばれる
        let ud = NSUserDefaults()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let viewController: UIViewController
        
        if (ud.objectForKey("UserName") != nil){
            viewController = storyboard.instantiateViewControllerWithIdentifier("home")
        }else{
            viewController = storyboard.instantiateViewControllerWithIdentifier("login")
        }
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        
        // ローカル通知の設定
        let notiSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        application.registerUserNotificationSettings(notiSettings)
        application.registerForRemoteNotifications()
        
        // バッジ消す
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            application.applicationIconBadgeNumber = 0
            application.cancelLocalNotification(notification)
        }
        
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
        }
        
        Fabric.with([Twitter.self])
        return true
    }
    
    
    // バックグラウンドから戻った時バッジ消す
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification){
        
        if application.applicationState != .Active {
            application.applicationIconBadgeNumber = 0
            application.cancelLocalNotification(notification)
        }else{
            if application.applicationIconBadgeNumber != 0 {
                application.applicationIconBadgeNumber = 0
                application.cancelLocalNotification(notification)
            }
        }
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        application.cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.alertAction = "ngoi"
        notification.alertBody = "食事の後はすぐに記録しましょう！"
        notification.fireDate = NSDate(timeInterval: 60*60*6, sinceDate: NSDate())
        notification.applicationIconBadgeNumber = 1
        notification.userInfo = ["notifyId":"ngo"]
        application.scheduleLocalNotification(notification)
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // バッジ消す
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

