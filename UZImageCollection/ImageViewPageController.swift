//
//  ImageViewPageController.swift
//  UZImageCollection
//
//  Created by sonson on 2015/06/08.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

func imageViewFrame2(sourceImageViewFrame:CGRect, destinationImageViewFrame:CGRect, imageSize:CGSize, contentMode:UIViewContentMode) -> (CGRect, CGRect) {
    
    var scaleToFitImageOverSourceImageView:CGFloat = 0
    let startFrame = sourceImageViewFrame
    var endFrame = CGRectZero
    let targetCenter = CGPointMake(CGRectGetMidX(sourceImageViewFrame), CGRectGetMidY(sourceImageViewFrame))
    
    if (contentMode == .ScaleAspectFill) {		// 画像一覧のサムネイルの場合
        // 画像の縦横の小さい方のサイズをビューに合わせる（はみ出す）→ビューの方の縦横の小さい方に合わせて画像スケールする
        if startFrame.size.width < startFrame.size.height {
            endFrame.size = CGSizeMake(startFrame.size.width, startFrame.size.width);
            endFrame.origin = CGPointMake(targetCenter.x - endFrame.size.width/2, targetCenter.y - endFrame.size.height/2);
            scaleToFitImageOverSourceImageView = sourceImageViewFrame.size.width / startFrame.size.width;
        }
        else {
            endFrame.size = CGSizeMake(startFrame.size.height, startFrame.size.height);
            endFrame.origin = CGPointMake(targetCenter.x - endFrame.size.width/2, targetCenter.y - endFrame.size.height/2);
            scaleToFitImageOverSourceImageView = sourceImageViewFrame.size.height / startFrame.size.height;
        }
    }
    else if (contentMode == .ScaleAspectFit) {	// サムネイルの場合
        // 画像の縦横の大きい方のサイズをビューに合わせる（はみ出さない）→ビューの方の縦横の大きい方に合わせて画像スケールする
        if imageSize.height / imageSize.width > sourceImageViewFrame.size.height / sourceImageViewFrame.size.width {
            endFrame = startFrame;
            endFrame.origin = CGPointMake(targetCenter.x - endFrame.size.width/2, targetCenter.y - endFrame.size.height/2);
            scaleToFitImageOverSourceImageView = sourceImageViewFrame.size.height / startFrame.size.height;
        }
        else {
            endFrame = startFrame;
            endFrame.origin = CGPointMake(targetCenter.x - endFrame.size.width/2, targetCenter.y - endFrame.size.height/2);
            scaleToFitImageOverSourceImageView = sourceImageViewFrame.size.width / startFrame.size.width;
        }
    }
    
    return (startFrame, endFrame)
}

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
                
//                self.imageCollectionViewController.collectionView?.reloadData()
//                let path = self.imageCollectionViewController.currentFocusedPath
//                let cell = self.imageCollectionViewController.collectionView?.cellForItemAtIndexPath(path)
//                if let cell = cell as? ImageCollectionViewCell {
//                    let destination = p.view.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
//                    let (s, e) = imageViewFrame2(destination, destinationImageViewFrame:destination, imageSize:image.size, contentMode:UIViewContentMode.ScaleAspectFill)
//                    
//                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
//                        p.view.addSubview(imageView)
//                        UIView.animateWithDuration(0.6,
//                            animations: { () -> Void in
//                                imageView.frame = destination
//                            }, completion: { (success) -> Void in
//                                imageView.removeFromSuperview()
//                        })
//                    })
//                }
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
    
//    func sourceAtIndex(index:Int) -> UIViewController? {
//        if let image = collection.image(index) {
////            let con = ImageViewController(index: index, image: image)
//        }
//        return nil
//    }
    
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
