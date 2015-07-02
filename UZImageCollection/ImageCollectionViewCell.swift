//
//  ImageCollectionViewCell.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String {
    var md5: String {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}

protocol ImageDownloader {
    var imageView:UIImageView {get}
    var indicator:UIActivityIndicatorView {get}
    
    var intrinsicImageURL:NSURL {set get}
    var imageURLHash:String {set get}
    var task:NSURLSessionDataTask? {set get}
    var imageURL:NSURL {set get}
    
//    func cachePath() -> String
//    func loadImageFromCache() -> UIImage?
//    func reload()
//    func startDownloadingImage()
//    func cancelDownloadingImage()
}

extension ImageDownloader {
    var imageURL:NSURL {
        get {
            return self.intrinsicImageURL
        }
        set (newValue){
            self.intrinsicImageURL = newValue
            self.imageURLHash = self.intrinsicImageURL.absoluteString.md5
        }
    }
}

class ImageCollectionViewCell: UICollectionViewCell, ImageDownloader {
    let imageView = UIImageView(frame: CGRectZero)
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    var intrinsicImageURL = NSURL()
    var imageURLHash = ""
    var task:NSURLSessionDataTask? = nil
    

//    var imageURL:NSURL {
//        get {
//            return self.intrinsicImageURL
//        }
//        set (newValue){
//            self.intrinsicImageURL = newValue
//            self.imageURLHash = self.intrinsicImageURL.absoluteString.md5
//        }
//    }
    
    func cachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let cacheRootPath:String = paths[0]
        let cachePath = cacheRootPath.stringByAppendingPathComponent("cache")
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: [:])
        } catch let error {
            print(error)
        }
        return cachePath.stringByAppendingPathComponent(imageURLHash)
    }
    
    func loadImageFromCache() -> UIImage? {
        if let image = UIImage(contentsOfFile: cachePath()) {
            return image
        }
        return nil
    }
    
    func reload() {
        // reload image
        if let image = loadImageFromCache() {
            imageView.image = image
            indicator.stopAnimating()
        }
        else {
            startDownloadingImage()
        }
    }
    
    func startDownloadingImage() {
        let request = NSURLRequest(URL: intrinsicImageURL)
        if let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data:NSData = data, let image = UIImage(data: data) {
                    print("finish downloading")
                    self.imageView.image = image
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
            })
            self.task = nil
        }) {
            indicator.startAnimating()
            self.task = task
            task.resume()
        }
    }
    
    func cancelDownloadingImage() {
        if let task = self.task {
            print("cancel")
            task.cancel()
        }
        indicator.stopAnimating()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        cancelDownloadingImage()
        indicator.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        indicator.hidesWhenStopped = true
        contentView.addSubview(imageView)
        contentView.addSubview(indicator)
        
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        imageView.backgroundColor = UIColor.greenColor()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-1-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))

        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    func setImage(image:UIImage) -> Void {
        self.imageView.image = image
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
