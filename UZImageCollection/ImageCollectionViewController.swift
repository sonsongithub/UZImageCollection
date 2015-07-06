//
//  ImageCollectionViewController.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import Foundation

func imageViewFrame(sourceImageViewFrame:CGRect, destinationImageViewFrame:CGRect, imageSize:CGSize, contentMode:UIViewContentMode) -> CGRect {
    
    var scaleToFitImageOverContainerView:CGFloat = 1.0		/**< アニメーションさせるビューを画面全体に引き伸ばすための比．アニメーションさせるビューの最終フレームサイズを決めるために使う． */
    
    if destinationImageViewFrame.size.width / destinationImageViewFrame.size.height < imageSize.width / imageSize.height {
        scaleToFitImageOverContainerView = destinationImageViewFrame.size.width / imageSize.width;
    }
    else {
        scaleToFitImageOverContainerView = destinationImageViewFrame.size.height / imageSize.height;
    }
    
    var endFrame = CGRectMake(0, 0, imageSize.width * scaleToFitImageOverContainerView, imageSize.height * scaleToFitImageOverContainerView);
    
    endFrame.origin.x = (destinationImageViewFrame.size.width - endFrame.size.width)/2
    endFrame.origin.y = (destinationImageViewFrame.size.height - endFrame.size.height)/2
    
    return endFrame
}

public class ImageCollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var cellSize:CGFloat = 0
    let collection:ImageCollection
    
    var animatingImageView:UIImageView? = nil
    var animatingBackgroundView:UIView? = nil
    var currentFocusedPath:NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    
    func numberOfItemsInLine() -> Int {
        return 3
    }
    
    init(collection:ImageCollection) {
        self.collection = collection
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }
    
    public required init(coder aDecoder: NSCoder) {
        self.collection = ImageCollection(newList: [])
        super.init(coder: aDecoder)
    }
    
    public class func controller(URLList:[NSURL]) -> ImageCollectionViewController {
        let collection = ImageCollection(newList: URLList)
        let vc = ImageCollectionViewController(collection:collection)
        return vc
    }
    
    public class func controllerInNavigationController(URLList:[NSURL]) -> UINavigationController {
        let collection = ImageCollection(newList: URLList)
        let vc = ImageCollectionViewController(collection:collection)
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.alwaysBounceVertical = true
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "focus:", name: "did", object: nil)
        
        cellSize = floor((self.view.frame.size.width - CGFloat(numberOfItemsInLine()) + 1) / CGFloat(numberOfItemsInLine()));
        
        self.title = String(format: NSLocalizedString("%ld images", comment: ""), arguments: [self.collection.count])
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let path = self.currentFocusedPath
        let cell = self.collectionView?.cellForItemAtIndexPath(path)
        print(cell)
        
        if let imageView = self.animatingImageView {
            let backgroundView = UIView(frame: self.view.bounds)
            backgroundView.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(backgroundView)
            self.view.addSubview(imageView)
            animatingBackgroundView = backgroundView
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let path = self.currentFocusedPath
        let cell = self.collectionView?.cellForItemAtIndexPath(path)
        if let imageView = self.animatingImageView {
            if let cell = cell as? ImageCollectionViewCell {
                cell.hidden = true
                self.view.addSubview(imageView)
                imageView.clipsToBounds = true
                
                let destination = self.view.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
                UIView.animateWithDuration(0.4,
                    animations: { () -> Void in
                        self.animatingBackgroundView?.alpha = 0
                        imageView.frame = destination
                    }, completion: { (success) -> Void in
                        imageView.removeFromSuperview()
                        self.animatingBackgroundView?.removeFromSuperview()
                        self.animatingImageView = nil
                        self.animatingBackgroundView = nil
                        cell.hidden = false
                })
            }
            else {
                UIView.animateWithDuration(0.4,
                    animations: { () -> Void in
                        imageView.alpha = 0
                        self.animatingBackgroundView?.alpha = 0
                    }, completion: { (success) -> Void in
                        imageView.removeFromSuperview()
                        self.animatingBackgroundView?.removeFromSuperview()
                        self.animatingImageView = nil
                        self.animatingBackgroundView = nil
                })
            }
        }
    }
    
    func focus(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            if let index = userInfo["index"] as? Int {
                self.currentFocusedPath = NSIndexPath(forItem: index, inSection: 0)
                if let collectionView = self.collectionView {
                    if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) {
                        if !collectionView.visibleCells().contains(cell) {
                            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
                        }
                    }
                    else{
                        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
                    }
                }
            }
        }
    }
}

extension ImageCollectionViewController {

    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.count
    }
    
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell {
            
            if let sourceImage = cell.fullImage() {
                
                cell.hidden = true
                
                let whiteBackgroundView = UIView(frame: self.view.bounds)
                whiteBackgroundView.alpha = 0
                whiteBackgroundView.backgroundColor = UIColor.whiteColor()
            
                let imageView = UIImageView(image: sourceImage)
                
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                
                self.view.addSubview(whiteBackgroundView)
                self.view.addSubview(imageView)
                let sourceRect = self.view.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
                
                let e = imageViewFrame(sourceRect, destinationImageViewFrame: self.view.bounds, imageSize: sourceImage.size, contentMode: UIViewContentMode.ScaleAspectFill)
                
                imageView.frame = sourceRect
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    imageView.frame = e
                    whiteBackgroundView.alpha = 1
                    }, completion: { (success) -> Void in
                        let con = ImageViewPageController.controller(self.collection, index: indexPath.row, imageCollectionViewController:self)
                        self.presentViewController(con, animated: false) { () -> Void in
                            imageView.removeFromSuperview()
                            whiteBackgroundView.removeFromSuperview()
                        }
                        
                        cell.hidden = false
                })
            
            }
            
        }
    }
    
    public override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ImageCollectionViewCell {
            cell.cancelDownloadingImage()
        }
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        cell.prepareForReuse()
        if let cell = cell as? ImageCollectionViewCell {
            let imageURL = collection.URLList[indexPath.row]
            cell.imageURL = imageURL
            cell.reload()
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize + 1)
    }
    
}
