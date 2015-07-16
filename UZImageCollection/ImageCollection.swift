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
}