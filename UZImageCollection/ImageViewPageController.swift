//
//  ImageViewPageController.swift
//  UZImageCollection
//
//  Created by sonson on 2015/06/08.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageViewPageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    let collection:ImageCollection
    var currentIndex = 0
    let navigationBar = UINavigationBar(frame: CGRectZero)
    let imageCollectionViewController:ImageCollectionViewController
    var imageViewController:ImageViewController? = nil
    let item:UINavigationItem = UINavigationItem(title:"")
    
    var isDark = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[navigationBar]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["navigationBar":navigationBar]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[navigationBar(==64)]", options: NSLayoutFormatOptions(), metrics: [:], views: ["navigationBar":navigationBar]))
        navigationBar.pushNavigationItem(item, animated: false)
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close:")
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        isDark = !isDark
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.navigationBar.alpha = self.isDark ? 0 : 1
            self.view.backgroundColor = self.isDark ? UIColor.blackColor() : UIColor.whiteColor()
            }, completion: { (success) -> Void in
        })
        
        navigationBar.hidden = isDark
        for viewController in self.childViewControllers {
            if let imageViewController = viewController as? ImageViewController {
                imageViewController.isDark = isDark
            }
        }
    }
    
    func close(sender:AnyObject) {
        if let imageViewController = self.imageViewController {
            if let animatedImageView = imageViewController.animatedImageView {
                self.imageCollectionViewController.animatingImageView = animatedImageView
            }
            else {
                if let p = self.presentingViewController, image = imageViewController.imageView.image {
                    print(imageViewController.imageView.frame)
                    print(imageViewController.scrollView.contentOffset)
                    print(p.view.frame)
                    print(imageViewController.scrollView.frame)
                    let x = imageViewController.imageView.frame.origin.x - imageViewController.scrollView.contentOffset.x
                    let y = imageViewController.imageView.frame.origin.y - imageViewController.scrollView.contentOffset.y
                    
                    // work around for iOS8
                    let startFrame = CGRect(x: x, y: y, width: imageViewController.imageView.frame.size.width, height: imageViewController.imageView.frame.size.height)
//                    let startFrame = p.view.convertRect(imageViewController.imageView.frame, fromView: imageViewController.imageView.superview)
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.frame = startFrame
                    self.imageCollectionViewController.animatingImageView = imageView
                }
            }
        }
        self.dismissViewControllerAnimated(false, completion: { () -> Void in })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(collection:ImageCollection, index:Int, imageCollectionViewController:ImageCollectionViewController) {
        self.collection = collection
        self.currentIndex = index
        self.imageCollectionViewController = imageCollectionViewController
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options:[UIPageViewControllerOptionInterPageSpacingKey:12])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didMoveCurrentImage:", name: ImageViewControllerDidChangeCurrentImage, object: nil)
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.collection = ImageCollection(newList:[])
        self.imageCollectionViewController = ImageCollectionViewController(collection: ImageCollection(newList: []))
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didMoveCurrentImage:", name: ImageViewControllerDidChangeCurrentImage, object: nil)
    }
    
    class func controller(collection:ImageCollection, index:Int, imageCollectionViewController:ImageCollectionViewController) -> ImageViewPageController {
        let vc = ImageViewPageController(collection:collection, index:index, imageCollectionViewController:imageCollectionViewController)
        let con = ImageViewController(index: index, imageCollectionViewController:imageCollectionViewController, isDark:false)
        vc.imageViewController = con
        vc.view.backgroundColor = UIColor.whiteColor()
        vc.setViewControllers([con], direction: .Forward, animated: false, completion: { (result) -> Void in })
        return vc
    }
    
    func didMoveCurrentImage(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            if let index = userInfo[ImageViewControllerDidChangeCurrentImageIndexKey] as? Int {
                item.title = collection.URLList[index].lastPathComponent
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let con = pageViewController.viewControllers?.last as? ImageViewController {
                self.imageViewController = con
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let index = viewController.index + 1
            if collection.count <= index {
                return nil
            }
            return ImageViewController(index: index, imageCollectionViewController:imageCollectionViewController, isDark:isDark)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let index = viewController.index - 1
            if index < 0 {
                return nil
            }
            return ImageViewController(index: index, imageCollectionViewController:imageCollectionViewController, isDark:isDark)
        }
        return nil
    }
}
