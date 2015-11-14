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
    static var cachedImages = [String:UIImage]()
    
    static func loadPosters(thumbnailURL:String, detailedURL:String, posterImageView:UIImageView) {
        
        if ImageManager.cachedImages[detailedURL] != nil {
            posterImageView.image = ImageManager.cachedImages[detailedURL]
            return
        }
        
        if ImageManager.cachedImages[thumbnailURL] != nil {
            posterImageView.image = ImageManager.cachedImages[thumbnailURL]
            
            loadImage(detailedURL, callBack: { (dynamicImage) -> Void in
                posterImageView.image = dynamicImage
                ImageManager.cachedImages[detailedURL] = dynamicImage
            })
            return
        }
        
        loadImage(thumbnailURL, callBack: { (image:UIImage) -> Void in
            
            fadeIn(posterImageView)
            
            posterImageView.image = image
            
            ImageManager.cachedImages[thumbnailURL] = image
            
            loadImage(detailedURL, callBack: { (dynamicImage) -> Void in
                posterImageView.image = dynamicImage
                ImageManager.cachedImages[detailedURL] = dynamicImage
            })
        })
    }
    
    static func loadImage(thumbnailURL:String, callBack: (dynamicImage:UIImage) -> Void) {
        Alamofire.request(.GET, thumbnailURL)
            .responseImage { response in
                
                if let image = response.result.value {
                    callBack(dynamicImage: image)
                }
        }
    }
    
    static func fadeIn(view:UIImageView) {
        view.alpha = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            view.alpha = 1
        }
    }

}