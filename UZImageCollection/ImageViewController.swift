//
//  ImageViewController.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, ImageDownloader {
    let index:Int
    let scrollView = UIScrollView(frame: CGRectZero)
    let imageView = UIImageView(frame: CGRectZero)
    let imageCollectionViewController:ImageCollectionViewController
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    
    var maximumZoomScale:CGFloat = 0
    var minimumZoomScale:CGFloat = 0
    var imageURL = NSURL()
    var task:NSURLSessionDataTask? = nil
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.index = 0
        self.imageCollectionViewController = ImageCollectionViewController(collection: ImageCollection(newList: []))
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            cancelDownloadingImage()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("did", object: nil, userInfo: ["index":self.index])
    }
    
    init(index:Int, imageCollectionViewController:ImageCollectionViewController) {
        self.index = index
        self.imageCollectionViewController = imageCollectionViewController
        scrollView.addSubview(imageView)
        super.init(nibName: nil, bundle: nil)
        if imageCollectionViewController.collection.URLList.indices ~= index {
            self.imageURL = imageCollectionViewController.collection.URLList[index]
        }
        reload(false)
    }
    
    class func controllerWithIndex(index:Int, imageCollectionViewController:ImageCollectionViewController) -> ImageViewController {
        let con = ImageViewController(index:index, imageCollectionViewController:imageCollectionViewController)
        return con
    }
}

extension ImageViewController {
    func setupScrollViewScale(imageSize:CGSize) {
        scrollView.frame = self.view.bounds;
        
        let boundsSize = self.view.bounds
        
        // calculate min/max zoomscale
        let xScale = boundsSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        let imagePortrait = imageSize.height > imageSize.width;
        let phonePortrait = boundsSize.height > imageSize.width;
        var minScale = imagePortrait == phonePortrait ? xScale : (xScale < yScale ? xScale : yScale);
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        let maxScale = 10.0 / UIScreen.mainScreen().scale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if (minScale > maxScale) {
            minScale = maxScale;
        }
        
        scrollView.maximumZoomScale = maxScale;
        scrollView.minimumZoomScale = minScale;
        
        scrollView.contentSize = imageView.image!.size
        scrollView.zoomScale = scrollView.minimumZoomScale;
    }
    
    func updateImageView(image:UIImage, thumbnail:UIImage?) {
        
        let path = self.cachePath()
        let data = NSData(contentsOfFile: path)
        let animatedImage:FLAnimatedImage? = FLAnimatedImage(animatedGIFData: data)
        
        let animatedView = FLAnimatedImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size))
        animatedView.contentMode = .ScaleAspectFit
        animatedView.animatedImage = animatedImage
        
        self.view.addSubview(animatedView)
        
        imageView.hidden = false
        self.imageView.image = image
        self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        self.setupScrollViewScale(image.size)
        self.updateImageCenter()
    }
    
    func updateImageCenter() {
        let boundsSize = self.view.bounds
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }
        else {
            frameToCenter.origin.x = 0;
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }
        else {
            frameToCenter.origin.y = 0;
        }
        
        imageView.frame = frameToCenter
    }
    
    func setupSubviews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.delegate = self
        scrollView.multipleTouchEnabled = true
        scrollView.backgroundColor = UIColor.whiteColor()
        self.view.multipleTouchEnabled = true
        self.navigationController?.view.multipleTouchEnabled = true
        
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["scrollView":scrollView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[scrollView]-1-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["scrollView":scrollView]))
        
        self.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
}

extension ImageViewController : UIScrollViewDelegate {
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.updateImageCenter()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.updateImageCenter()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}