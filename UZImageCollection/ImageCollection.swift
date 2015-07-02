//
//  ImageCollection.swift
//  UZImageCollectionView
//
//  Created by sonson on 2015/06/05.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import Foundation

class ImageCollection {
    let URLList:[NSURL]
    
    init(newList:[NSURL]) {
        URLList = newList
    }
    
    var count:Int {
        return URLList.count
    }
    
//    func image(index:Int) -> UIImage? {
//        if (index >= 0 && index < files.count) {
//            let file = files[index]
////            let image = UIImage(contentsOfFile: file)
//            let image = UIImage(named: file)
//            if let image = image {
//                return image
//            }
//        }
//        return nil
//    }
}