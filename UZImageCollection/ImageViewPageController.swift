//
//  ImageViewPageController.swift
//  UZImageCollection
//
//  Created by sonson on 2015/06/08.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageViewPageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let collection:ImageCollection
    var currentIndex = 0
    let navigationBar = UINavigationBar(frame: CGRectZero)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(navigationBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[navigationBar]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: [:], views: ["navigationBar":navigationBar]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[navigationBar(==64)]", options: NSLayoutFormatOptions.allZeros, metrics: [:], views: ["navigationBar":navigationBar]))
        navigationBar.pushNavigationItem(UINavigationItem(title: "a"), animated: false)
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close:")
    }
    
    func close(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(collection:ImageCollection, index:Int) {
        self.collection = collection
        self.currentIndex = index
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options:[UIPageViewControllerOptionInterPageSpacingKey:12])
        self.dataSource = self
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        self.collection = ImageCollection(files:[])
        super.init(coder: aDecoder)
    }
    
    class func controller(collection:ImageCollection, index:Int) -> ImageViewPageController {
        let vc = ImageViewPageController(collection:collection, index:index)
        if let image = collection.image(index) {
            let con = ImageViewController(index: index, image: image)
            vc.view.backgroundColor = UIColor.blackColor()
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
