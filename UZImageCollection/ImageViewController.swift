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
    
    var  maximumZoomScale:CGFloat = 0
    var  minimumZoomScale:CGFloat = 0

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
        
        scrollView.frame = self.view.bounds;
        
        let imageSize = imageView.image!.size ?? CGSizeZero
        
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
        let maxScale = 2.0 / UIScreen.mainScreen().scale
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("did", object: nil, userInfo: ["index":self.index])
    }
    
    init(index:Int, image:UIImage, imageCollectionViewController:ImageCollectionViewController) {
        self.index = index
        imageView.image = image
        scrollView.addSubview(imageView)
        self.imageCollectionViewController = imageCollectionViewController
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.index = 0
        self.imageCollectionViewController = ImageCollectionViewController(coder: aDecoder)
        super.init(coder: aDecoder)
    }
    
    class func controllerWithIndex(index:Int, image:UIImage, imageCollectionViewController:ImageCollectionViewController) -> ImageViewController {
        let con = ImageViewController(index:index, image:image, imageCollectionViewController:imageCollectionViewController)
        return con
    }
}
