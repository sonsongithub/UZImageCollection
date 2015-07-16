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
        
        var paths:[String] = []
        
        for var i = 1; i <= 11; i++ {
            paths.append("pict - \(i).png")
        }
        for var i = 1; i <= 11; i++ {
            paths.append("pict - \(i).png")
        }
        
        let vc = ImageCollectionViewController.controller(paths)
        self.presentViewController(vc, animated: true, completion: { () -> Void in })
    }
}

