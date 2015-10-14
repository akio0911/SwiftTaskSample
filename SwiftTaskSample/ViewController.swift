//
//  ViewController.swift
//  SwiftTaskSample
//
//  Created by akio0911 on 2015/10/14.
//  Copyright © 2015年 akio0911. All rights reserved.
//

import UIKit
import SwiftTask

typealias Progress = Float
typealias Value = String
typealias Error = NSError

typealias MyTask = Task<Progress, Value, Error>

let myError = NSError(domain: "MyErrorDomain", code: 0, userInfo: nil)

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.example1()
        self.example2()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func example1() {
        // Example 1: Sync fullfilled -> success
        print("Example 1")
        
        let task = MyTask(value: "Hello")
            .success { value -> String in
                return "\(value) World"
            }
            .success { value -> String in
                return "\(value)!!!"
        }
        print(task.value) // Optional("Hello World!!!")
        
        // Example 2: Sync rejected -> success -> failure
        print("Example 2")
        
        let task2a = MyTask(error: myError)
            .success { value -> String in
                return "Never reaches here..."
        }
        
        let task2b = task2a
            .failure { (error, isCancelled) -> String in
                return "ERROR: \(error!.domain)" // recovery from failure
        }
        
        print(task2a.value) // nil
        print(task2a.errorInfo) // Optional((Optional(Error Domain=MyErrorDomain Code=0 "(null)"), false))
        print(task2b.value) // Optional("ERROR: MyErrorDomain")
        print(task2b.errorInfo) // nil
        
        // Example 3: Sync fulfilled or rejected -> then
        print("Example 3")
        
        // fulfills or rejects immediately
        
        let task3a = MyTask { (progress, fulfill, reject, configure) -> Void in
            if arc4random_uniform(2) == 0 {
                fulfill("Hello")
            }
            else {
                reject(myError)
            }
        }
        let task3b = task3a
            .then { (value, errorInfo) -> String in
                if let errorInfo = errorInfo {
                    return "ERROR: \(errorInfo.error!.domain)"
                }
                return "\(value!) World"
        }
        
        // 【成功した場合】
        print(task3a.value) // Optional("Hello")
        print(task3a.errorInfo) // nil
        print(task3b.value) // Optional("Hello World")
        print(task3b.errorInfo) // nil
        
        // 【失敗した場合】
        print(task3a.value) // nil
        print(task3a.errorInfo) //  Optional((Optional(Error Domain=MyErrorDomain Code=0 "(null)"), false))
        print(task3b.value) // Optional("ERROR: MyErrorDomain")
        print(task3b.errorInfo) // nil
    }
    
    func example2() {
        // fulfills after 100ms
        func asyncTask(value: String) -> MyTask
        {
            return MyTask { progress, fulfill, reject, configure in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100_000_000), dispatch_get_main_queue()) {
                    fulfill(value)
                }
            }
        }
        
        // Example 1: Async
        
        print("Example 1")
        
        let task1a = asyncTask("Hello")
        let task1b = task1a
            .success { value -> String in
                print("value")
                return "\(value) World"
        }
        // NOTE: these values should be all nil because task is async
        print(task1a.value) // nil
        print(task1a.errorInfo) // nil
        print(task1b.value) // nil
        print(task1b.errorInfo) // nil
        
        // Example 2: Async chaining
        
        print("Example 2")
        
        let task2a = asyncTask("Hello")
        let task2b = task2a
            .success { value -> MyTask in
                print(value) // Hello
                return asyncTask("\(value) Cruel")  // next async
            }
            .success { value -> String in
                print(value) // Hello Cruel
                return "\(value) World"
        }
    }
}



