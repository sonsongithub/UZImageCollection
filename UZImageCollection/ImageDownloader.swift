//
//  ImageDownloader.swift
//  UZImageCollection
//
//  Created by sonson on 2015/07/03.
//  Copyright © 2015年 sonson. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
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

protocol ImageDownloader : class {
    var imageView:UIImageView {get}
    var indicator:UIActivityIndicatorView {get}
    
    var imageURLHash:String {get}
    var task:NSURLSessionDataTask? {set get}
    var imageURL:NSURL {set get}
    var errorImage:UIImage {get}
    
    func cachePath() -> String
    func loadImageFromCache() -> UIImage?
    func reload(decelerating:Bool)
    func startDownloadingImage()
    func cancelDownloadingImage()
    func updateImageView(image:UIImage, thumbnail:UIImage?)
}

extension ImageDownloader {
    
    var errorImage:UIImage {
        return UIImage(named: "errorImage")!
    }
    
    var imageURLHash:String {
        return self.imageURL.absoluteString.md5
    }
    
    func createThumbnail(image:UIImage) -> UIImage {
        let scale = image.size.width > image.size.height ? 240 / image.size.width : 240 / image.size.height
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    func loadImageFromCache() -> UIImage? {
        if let image = UIImage(contentsOfFile: cachePath()) {
            return image
        }
        return nil
    }
    
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
    
    func thumbnailPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let cacheRootPath:String = paths[0]
        let cachePath = cacheRootPath.stringByAppendingPathComponent("thumbnail")
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: [:])
        } catch let error {
            print(error)
        }
        return cachePath.stringByAppendingPathComponent(imageURLHash)
    }
    
    func startDownloadingImage() {
        if self.task != nil {
            return
        }
        
        let request = NSURLRequest(URL: imageURL)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) -> Void in
            var originalImage:UIImage? = nil
            var thumbnailImage:UIImage? = nil
            // save image
            if let data:NSData = data, let image = UIImage(data: data) {
                let resizedImage = self.createThumbnail(image)
                if let resizedData = UIImagePNGRepresentation(resizedImage) {
                    resizedData.writeToFile(self.thumbnailPath(), atomically: false)
                }
                data.writeToFile(self.cachePath(), atomically: false)
                
                originalImage = image
                thumbnailImage = resizedImage
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.indicator.stopAnimating()
                if self.imageURL == request.URL {
                    // load image
                    if let originalImage = originalImage {
                        self.updateImageView(originalImage, thumbnail:thumbnailImage)
                    }
                    else {
                        self.imageView.hidden = false
                        self.updateImageView(self.errorImage, thumbnail:nil)
                    }
                }
            })
            self.task = nil
        })
        if let task = task {
            self.imageView.hidden = true
            indicator.startAnimating()
            self.task = task
            task.resume()
        }
    }
    
    func reload(decelerating:Bool) {
        // reload image
        
        if let image = loadImageFromCache() {
            updateImageView(image, thumbnail:nil)
            indicator.stopAnimating()
        }
        else if !decelerating {
            self.imageView.hidden = true
            startDownloadingImage()
        }
        else {
            self.imageView.hidden = true
            indicator.startAnimating()
        }
    }
    
    func cancelDownloadingImage() {
        if let task = self.task {
            print("try to cancel - \(self.imageURL.absoluteString)")
            task.cancel()
            self.task = nil
        }
        indicator.stopAnimating()
    }
}
