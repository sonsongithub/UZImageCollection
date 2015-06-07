//
//  ImageViewPageController.swift
//  UZImageCollection
//
//  Created by sonson on 2015/06/08.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageViewPageController: UIPageViewController, UIPageViewControllerDataSource {
    let collection:ImageCollection
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init(collection:ImageCollection, index:Int) {
        self.collection = collection
        self.currentIndex = index
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options:[:])
        self.dataSource = self
    }
    
    required init(coder aDecoder: NSCoder) {
        self.collection = ImageCollection(files:[])
        super.init(coder: aDecoder)
    }
    
    class func controller(collection:ImageCollection, index:Int) -> ImageViewPageController {
        let vc = ImageViewPageController(collection:collection, index:index)
        if let image = collection.image(index) {
            let con = ImageViewController(index: index, image: image)
            vc.setViewControllers([con], direction: .Forward, animated: false, completion: { (result) -> Void in })
        }
        return vc
    }
    
    func sourceAtIndex(index:Int) -> UIViewController? {
        if let image = collection.image(index) {
            let con = ImageViewController(index: index, image: image)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let index = viewController.index + 1
            if let image = collection.image(index) {
                return ImageViewController(index: index, image: image)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let index = viewController.index - 1
            if let image = collection.image(index) {
                return ImageViewController(index: index, image: image)
            }
        }
        return nil
    }
}
