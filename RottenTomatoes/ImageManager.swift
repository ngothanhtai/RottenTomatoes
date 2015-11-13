//
//  ImageManager.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/11/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ImageManager {
    static var cachedImages = [Int:UIImage]()
    
    static func loadPosters(thumbnailURL:String, detailedURL:String, indexPath:NSIndexPath, posterImageView:UIImageView) {
        
        if ImageManager.cachedImages[indexPath.row] != nil {
            posterImageView.image = ImageManager.cachedImages[indexPath.row]
            return
        }
        
        loadThumbnail(thumbnailURL, callBack: { (image:UIImage) -> Void in
            posterImageView.image = image
            
            ImageManager.cachedImages[indexPath.row] = image
            
            self.loadThumbnail(detailedURL, callBack: { (dynamicImage) -> Void in
                posterImageView.image = dynamicImage
                ImageManager.cachedImages[indexPath.row] = dynamicImage
            })
        })
    }
    
    static func loadThumbnail(thumbnailURL:String, callBack: (dynamicImage:UIImage) -> Void) {
        Alamofire.request(.GET, thumbnailURL)
            .responseImage { response in
                
                if let image = response.result.value {
                    callBack(dynamicImage: image)
                }
        }
    }

}