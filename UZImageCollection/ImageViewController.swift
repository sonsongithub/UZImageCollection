//
//  ImageViewController.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    let index:Int
    let scrollView = UIScrollView(frame: CGRectZero)
    let imageView = UIImageView(frame: CGRectZero)
    let imageCollectionViewController:ImageCollectionViewController
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    
    var  maximumZoomScale:CGFloat = 0
    var  minimumZoomScale:CGFloat = 0
    var intrinsicImageURL = NSURL()
    var imageURLHash = ""
    var task:NSURLSessionDataTask? = nil
    
    func reload() {
        // reload image
        if let image = loadImageFromCache() {
            imageView.image = image
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
            indicator.stopAnimating()
            updateImageView()
        }
        else {
            startDownloadingImage()
        }
    }
    
    func cachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let cacheRootPath:String = paths[0]
        let cachePath = cacheRootPath.stringByAppendingPathComponent("cache")
        return cachePath.stringByAppendingPathComponent(imageURLHash)
    }
    
    func loadImageFromCache() -> UIImage? {
        if let image = UIImage(contentsOfFile: cachePath()) {
            return image
        }
        return nil
    }
    
    func startDownloadingImage() {
        let request = NSURLRequest(URL: intrinsicImageURL)
        if let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data:NSData = data, let image = UIImage(data: data) {
                    print("finish downloading")
                    self.imageView.image = image
                    self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
                    data.writeToFile(self.cachePath(), atomically: false)
                }
                else {
                    print("error downloading")
                    self.imageView.backgroundColor = UIColor.grayColor()
                }
                if let error = error {
                    print(error.description)
                }
                self.indicator.stopAnimating()
                self.updateImageView()
            })
            self.task = nil
        }) {
            indicator.startAnimating()
            self.task = task
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                NSThread.sleepForTimeInterval(2)
                task.resume()
            })
        }
    }
    
    func cancelDownloadingImage() {
        if let task = self.task {
            print("cancel")
            task.cancel()
        }
        indicator.stopAnimating()
    }
    
    var imageURL:NSURL {
        get {
            return intrinsicImageURL
        }
        set (newValue){
            intrinsicImageURL = newValue
            imageURLHash = intrinsicImageURL.absoluteString.md5
        }
    }
    
    func updateImageView() {
        
        if imageView.image != nil {
            scrollView.frame = self.view.bounds;
            
            let imageSize = imageView.image!.size ?? CGSizeZero
            
            print(imageSize)
            
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
            self.updateImageCenter()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.updateImageCenter()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.updateImageCenter()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateImageView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.imageURL = imageCollectionViewController.collection.URLList[index]
        reload()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.index = 0
        self.imageCollectionViewController = ImageCollectionViewController(coder: aDecoder)
        super.init(coder: aDecoder)
    }
    
    class func controllerWithIndex(index:Int, imageCollectionViewController:ImageCollectionViewController) -> ImageViewController {
        let con = ImageViewController(index:index, imageCollectionViewController:imageCollectionViewController)
        return con
    }
}
