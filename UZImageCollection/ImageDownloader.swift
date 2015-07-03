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
    
    func cachePath() -> String
    func loadImageFromCache() -> UIImage?
    func reload()
    func startDownloadingImage()
    func cancelDownloadingImage()
    func updateImageView(image:UIImage)
}

extension ImageDownloader {
    
    var imageURLHash:String {
        return md5(self.imageURL.absoluteString)
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
    
    func startDownloadingImage() {
        let request = NSURLRequest(URL: imageURL)
        if let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data:NSData = data, let image = UIImage(data: data) {
                    print("finish downloading")
                    self.updateImageView(image)
                    data.writeToFile(self.cachePath(), atomically: false)
                }
                else {
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
            updateImageView(image)
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
