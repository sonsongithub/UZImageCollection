//
//  ImageCollectionViewCell.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit
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

class ImageCollectionViewCell: UICollectionViewCell {
    static let sharedSession = NSURLSession()
    let imageView = UIImageView(frame: CGRectZero)
    let indicator = UIActivityIndicatorView(activityIndicatorStyle:.Gray)
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        print("removeFromSuperview")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("prepareForReuse")
        print(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(indicator)
        
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        imageView.backgroundColor = UIColor.greenColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-1-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["imageView":imageView]))

        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        indicator.startAnimating()
    }
    
    func setImage(image:UIImage) -> Void {
        self.imageView.image = image
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
