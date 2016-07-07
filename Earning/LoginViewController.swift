//
//  LoginViewController.swift
//  Earning
//
//  Created by Yusaku Eigen on 2016/06/10.
//  Copyright © 2016年 栄元優作. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController, NSURLSessionTaskDelegate {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                    )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                    (action) -> Void in
                    self.userDefaults.setObject(unwrappedSession.userName, forKey: "UserName")
                    self.performSegueWithIdentifier("GoHome", sender: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
         //TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //userDefaults.removeObjectForKey("FitbitID")
        
        // 二回目以降のログイン
//        if (userDefaults.objectForKey("UserName") != nil) {
//            goHome()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
