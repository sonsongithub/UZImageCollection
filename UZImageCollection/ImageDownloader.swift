//
//  ImageDownloader.swift
//  UZImageCollection
//
//  Created by sonson on 2015/07/03.
//  Copyright © 2015年 sonson. All rights reserved.
//

import Foundation

protocol ImageDownloader : class {
    var imageView:UIImageView {get}
    var indicator:UIActivityIndicatorView {get}
    
    var imageURLHash:String {get}
    var task:NSURLSessionDataTask? {set get}
    var imageURL:NSURL {set get}
    var errorImage:UIImage {get}
    
    func cachePath() -> String
    func loadImageFromCache() -> UIImage?
    func reload()
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
        let request = NSURLRequest(URL: imageURL)
        if let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data:NSData = data, let image = UIImage(data: data) {
                    print("finish downloading")
                    let resizedImage = self.createThumbnail(image)
                    if let resizedData = UIImagePNGRepresentation(resizedImage) {
                        resizedData.writeToFile(self.thumbnailPath(), atomically: false)
                    }
                    data.writeToFile(self.cachePath(), atomically: false)
                    self.updateImageView(image, thumbnail:resizedImage)
                    NSNotificationCenter.defaultCenter().postNotificationName("didDownloadImage", object: nil, userInfo: ["URL":self.imageURLHash])
                }
                else {
                    self.updateImageView(self.errorImage, thumbnail:nil)
                    print("error downloading")
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
    
    func reload() {
        // reload image
        if let image = loadImageFromCache() {
            updateImageView(image, thumbnail:nil)
            indicator.stopAnimating()
        }
        else {
            startDownloadingImage()
        }
    }
    
    func cancelDownloadingImage() {
        if let task = self.task {
            print("cancel")
            task.cancel()
            self.task = nil
        }
        indicator.stopAnimating()
    }
}
