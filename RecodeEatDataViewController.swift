//
//  recodeEatDataViewController.swift
//  Earning
//
//  Created by Yusaku Eigen on 2016/06/09.
//  Copyright © 2016年 栄元優作. All rights reserved.
//

import UIKit
import CoreLocation
import SCLAlertView
import CoreMotion

class RecordEatDataViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet weak var questionPicker: UIPickerView!
    
    var mylocationManager: CLLocationManager!
    
    var pickedImage:UIImage!
    
    let userDefaults = NSUserDefaults()
    
    var cameraFlag = 0
    
    var questions = ["全く食べ過ぎていない", "あまり食べ過ぎていない","どちらでもない","すこし食べ過ぎた","非常に食べ過ぎた"]
    var questions2 = ["Breakfast", "Lunch", "Dinner", "Between Meals"]
    
    var questionCount: Int!
    var questionText: String!
    
    var answer: Int!
    var answer2: String!
    
    
    var lat: Float!
    var lon: Float!
    
    var steps: NSNumber!
    
    var result: NSString!
    
    var alertView = SCLAlertView()
    
    let pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bg2.png")!)
        
        mylocationManager = CLLocationManager()
        mylocationManager.delegate = self
        mylocationManager.desiredAccuracy = kCLLocationAccuracyBest
        mylocationManager.distanceFilter = 100
        mylocationManager.startUpdatingLocation()
        
        questionPicker.delegate = self
        questionPicker.dataSource = self
        
    }
    
    
    
    // viewの描画が終わったあとに呼ばれる
    override func viewDidAppear(animated: Bool) {
        if cameraFlag == 0 {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                
                let cameraPicker = UIImagePickerController()
                
                cameraPicker.sourceType = sourceType
                cameraPicker.allowsEditing = true
                cameraPicker.delegate = self
                self.presentViewController(cameraPicker, animated: true, completion: nil)
                
            }
            cameraFlag = 1
        }
        
    }
    
    
    
    // 写真の選択が終わったあとに呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if pickedImage != nil {
            cameraView.contentMode = .ScaleAspectFit
            cameraView.image = pickedImage
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
//     描画が終わった後に呼ばれる
//    override func viewDidAppear(animated: Bool) {
//        
//        if cameraFlag == 0 {
//            let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
//            
//            // カメラが利用可能かチェック
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
//                
//                // インスタンスの作成
//                let cameraPicker = UIImagePickerController()
//                cameraPicker.sourceType = sourceType
//                cameraPicker.delegate = self
//                self.presentViewController(cameraPicker, animated: true, completion: nil)
//                
//                mylocationManager.startUpdatingLocation()
//                getSteps()
//                
//            }
//            else{
//                print("error")
//            }
//            cameraFlag = 1
//        }
//        
//    }
//    
//    
//     撮影が完了時した時に呼ばれる
//        func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//    
//            pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//            if (pickedImage != nil) {
//                cameraView.contentMode = .ScaleAspectFit
//                cameraView.image = pickedImage
//            }
//    
//            // 閉じる処理
//            imagePicker.dismissViewControllerAnimated(true, completion: nil)
//        
//        }
    
    
    // 歩数を取得する
    func getSteps() {
        
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
        let dataComp = calendar.components(unitFlags, fromDate: NSDate())
        //print(calendar.dateFromComponents(dataComp))
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startPedometerUpdatesFromDate(calendar.dateFromComponents(dataComp)!, withHandler:{
                (data, error) -> Void in
                if data != nil && error == nil{
                    self.steps = data?.numberOfSteps
                    print(self.steps)
                }else{
                }
            })
        }else{
            print("isNotAvailable")
        }
    }
    
    
    // 認証が終わってない時に呼ばれる
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            mylocationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            break
        case .Authorized, .AuthorizedWhenInUse:
            break
        }
    }
    
    
    
    
    // 送信前にデータがあるかチェック
    @IBAction func dataCheck(sender: AnyObject) {
        if (pickedImage != nil && answer != nil && answer2 != nil) {
            mylocationManager.startUpdatingLocation()
            getSteps()
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            alertView = SCLAlertView(appearance: appearance)
            alertView.showWait("Please Wait", subTitle: "Now Sending your data. Please Wait")
            
            uploadData()
        }else{
            alertView.showError("STOP", subTitle:"Plese take picture or choose level")
        }
    }

    
    // データ（画像、満腹度、緯度経度、時刻）を送信
    func uploadData() {
        let url = NSURL(string: "https://life-cloud.ht.sfc.keio.ac.jp/~eigen/EatWarning/upload.php")!
        let request = NSMutableURLRequest(URL: url)
        let name = userDefaults.objectForKey("UserName")!
        
        if steps == nil {
            steps = 0
        }
        
        let size = CGSize(width: 560, height: 600)
        UIGraphicsBeginImageContext(size)
        pickedImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let postimg = UIImageJPEGRepresentation(resizeImage, 1.0)
        request.HTTPMethod = "POST"
        
        let body = NSMutableData()
        let boundary = "__Eating"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"UserName\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(name)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"Steps\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(steps)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"lat\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(lat)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"lon\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(lon)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"Level\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(answer)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"Type\"r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\(answer2)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"filename\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: image/jpg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(postimg!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error == nil{
                let httpResponse = response as? NSHTTPURLResponse
                if(httpResponse?.statusCode == 200){
                    self.result = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(self.result!)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alertView.showSuccess("Success", subTitle: "Your data could send completely", duration: 1.0)
                        HomeViewController().dayCount = 0
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else{
                    print(httpResponse)
                }
            }else{
                print("postできなかったよ")
            };
        }
        task.resume()
    }
    
    
    
    //　通信が成功した時に呼ばれる
    func successAlert(){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.showSuccess("Succes", subTitle: "Return Home",duration: 2.0)
    }
    
    
    // 位置情報取得成功時に呼ばれる
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        lat = Float(newLocation.coordinate.latitude)
        lon = Float(newLocation.coordinate.longitude)
        print("緯度："+String(lat))
        print("経度："+String(lon))
    }
    
    // 位置情報取得失敗時に呼ばれる
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        print("error")
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            questionCount = questions.count
        }else if component == 1{
            questionCount = questions2.count
        }
        
        return questionCount
        
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            questionText = questions[row] as String
        }
        if component == 1 {
            questionText = questions2[row] as String
        }
        return questionText
    }
    
    //選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            answer = row + 1
            print(answer)
        }
        if component == 1 {
            answer2 = questions2[row]
            print(answer2)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addBackHome(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


