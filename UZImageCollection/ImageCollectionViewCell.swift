//
//  ImageCollectionViewCell.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, ImageDownloader {
    let imageView = FLAnimatedImageView(frame: CGRectZero)
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    var imageURL = NSURL()
    var task:NSURLSessionDataTask? = nil
    
    func updateImageView(image:UIImage, thumbnail:UIImage?) {
        imageView.hidden = false
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadingImage()
        indicator.stopAnimating()
        imageView.hidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}
