//
//  ViewController.swift
//  UZImageCollectionSample
//
//  Created by sonson on 2015/06/07.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit
import UZImageCollection

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let path = NSBundle.mainBundle().pathForResource("img.json", ofType: ""), let data = NSData(contentsOfFile: path) else {return}
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            if let list = json as? [String] {
                
                let URLList = list.flatMap({(string)->NSURL? in
                    if let url = NSURL(string:string) { return url }
                    return nil
                })
                let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                let cacheRootPath:String = paths[0]
                let cachePath = cacheRootPath.stringByAppendingPathComponent("cache")
                for url in URLList {
                    let path = cachePath.stringByAppendingPathComponent(url.absoluteString.md5)
                    
                    do {
//                        try NSFileManager.defaultManager().removeItemAtPath(path)
                    } catch let error {
//                        print(error)
                    }
                }
                
                let vc = ImageCollectionViewController.controllerInNavigationController(URLList)
                self.presentViewController(vc, animated: true, completion: { () -> Void in })

            }
        } catch _ {
            
        }  
    }
}

