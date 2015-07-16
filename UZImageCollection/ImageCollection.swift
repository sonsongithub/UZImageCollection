//
//  ImageCollection.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import Foundation

public class ImageCollection {
    var files:[String] = []
    
    public init(files:[String]) {
        self.files.extend(files)
    }
    
    var count:Int {
        return files.count
    }
    
    public func image(index:Int) -> UIImage? {
        if (index >= 0 && index < files.count) {
            let file = files[index]
//            let image = UIImage(contentsOfFile: file)
            let image = UIImage(named: file)
            if let image = image {
                return image
            }
        }
        return nil
    }
}