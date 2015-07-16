//
//  ImageCollectionViewCell.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        imageView.backgroundColor = UIColor.greenColor()
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: [:], views: ["imageView":imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-1-|", options: NSLayoutFormatOptions.allZeros, metrics: [:], views: ["imageView":imageView]))
    }
    
    func setImage(image:UIImage) -> Void {
        self.imageView.image = image
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
