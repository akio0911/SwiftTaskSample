//
//  LocationViewController.swift
//  SwiftTaskSample
//
//  Created by akio0911 on 2015/10/18.
//  Copyright © 2015年 akio0911. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftTask

class LocationViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lngLabel: UILabel!
    
    let coreLocationManager1 = CoreLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func pressButton(sender: AnyObject) {
        self.coreLocationManager1.requestLocationTask().success { location -> Task<Float, String, NSError> in
            let latString = NSString(format: "%.4f", location.coordinate.latitude) as String
            self.latLabel.text = "緯度:" + latString
            
            let longString = NSString(format: "%.4f", location.coordinate.longitude) as String
            self.lngLabel.text = "経度:" + longString
            
            return reverseGeocodeLocationTask(location)
        }.success { (address) -> Void in
            self.addressLabel.text = address
        }.failure { (error, isCancelled) -> Void in
            if let err = error {
                print("error = \(err.localizedDescription)")
            }
        }
    }
}

// reverseGeocodeLocation をpromise化
func reverseGeocodeLocationTask(location : CLLocation) -> Task<Float, String, NSError> {
    return Task(initClosure: { (progress, fulfill, reject, configure) -> Void in
        let myGeocorder = CLGeocoder()
        
        myGeocorder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let err = error {
                reject(err)
                return
            }
            
            for placemark in placemarks! {
                let address = ""
                    + (placemark.postalCode ?? "")
                    + (placemark.administrativeArea ?? "")
                    + (placemark.locality ?? "")
                    + (placemark.name ?? "")
                fulfill(address)
            }
        })
    })
}

// requestLocation や didUpdateLocations にまつわる処理をpromise化するためのクラス
class CoreLocationManager : NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var fulfill = { (_:CLLocation) -> Void in }
    var reject  = { (_:NSError) -> Void in }
    
    func requestLocationTask() -> Task<Float, CLLocation, NSError> {
        self.locationManager.requestWhenInUseAuthorization()
        return Task(initClosure: { (progress, fulfill, reject, configure) -> Void in
            self.fulfill = fulfill
            self.reject = reject
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            reject( NSError(domain: "Can't get location", code: 0, userInfo: nil) )
            return
        }
        
        fulfill(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        reject( NSError(domain: "Can't get location", code: 0, userInfo: nil) )
    }
}
