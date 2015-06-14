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
    let imageCollectionViewController:ImageCollectionViewController
    var imageViewController:ImageViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationBar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[navigationBar]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["navigationBar":navigationBar]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[navigationBar(==64)]", options: NSLayoutFormatOptions(), metrics: [:], views: ["navigationBar":navigationBar]))
        navigationBar.pushNavigationItem(UINavigationItem(title: "a"), animated: false)
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close:")
    }
    
    func close(sender:AnyObject) {
        if let imageViewController = self.imageViewController {
            if let p = self.presentingViewController, image = imageViewController.imageView.image {
                let startFrame = p.view.convertRect(imageViewController.imageView.frame, fromView: imageViewController.imageView.superview)
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.frame = startFrame
                self.imageCollectionViewController.animatingImageView = imageView
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
        self.dataSource = self
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        self.collection = ImageCollection(files:[])
        self.imageCollectionViewController = ImageCollectionViewController(coder: aDecoder)
        super.init(coder: aDecoder)
    }
    
    class func controller(collection:ImageCollection, index:Int, imageCollectionViewController:ImageCollectionViewController) -> ImageViewPageController {
        let vc = ImageViewPageController(collection:collection, index:index, imageCollectionViewController:imageCollectionViewController)
        if let image = collection.image(index) {
            let con = ImageViewController(index: index, image:image, imageCollectionViewController:imageCollectionViewController)
            vc.imageViewController = con
            vc.view.backgroundColor = UIColor.whiteColor()
            vc.setViewControllers([con], direction: .Forward, animated: false, completion: { (result) -> Void in })
        }
        return vc
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
            if let image = collection.image(index) {
                return ImageViewController(index: index, image: image, imageCollectionViewController:imageCollectionViewController)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageViewController {
            let index = viewController.index - 1
            if let image = collection.image(index) {
                return ImageViewController(index: index, image: image, imageCollectionViewController:imageCollectionViewController)
            }
        }
        return nil
    }
}
