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

class ImageCollectionViewCell: UICollectionViewCell, ImageDownloader {
    let imageView = UIImageView(frame: CGRectZero)
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    var imageURL = NSURL()
    var task:NSURLSessionDataTask? = nil
    
    func updateImageView(image:UIImage, thumbnail:UIImage?) {
        if let thumbnail = thumbnail {
            self.imageView.image = thumbnail
        }
        else {
            self.imageView.image = image
        }
    }
    
    func fullImage() -> UIImage? {
        return UIImage(contentsOfFile: cachePath())
    }
    
    func loadImageFromCache() -> UIImage? {
        if let image = UIImage(contentsOfFile: thumbnailPath()) {
            return image
        }
        return nil
    }
    
    func didDownloadImage(notification:NSNotification) {
        if let hash = notification.userInfo.flatMap({(obj)->String? in
            if let userInfo = obj as? [String:AnyObject], let hash = userInfo["URL"] as? String {
                return hash
            }
            return nil
        }) {
            if hash == self.imageURLHash {
                cancelDownloadingImage()
                if let thumbnail = loadImageFromCache() {
                    self.imageView.image = thumbnail
                }
            }
        }
    }
    
    func setupSubviews() {
        indicator.hidesWhenStopped = true
        contentView.addSubview(imageView)
        contentView.addSubview(indicator)
        
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        imageView.backgroundColor = UIColor.clearColor()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-1-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDownloadImage:", name: "didDownloadImage", object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        cancelDownloadingImage()
        indicator.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}
