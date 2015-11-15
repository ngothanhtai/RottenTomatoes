//
//  ImageManager.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/11/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking

class ImageManager {
    
    static func loadPosters(thumbnailURL:String, detailedURL:String, posterImageView:UIImageView)
    
    {
        ImageManager.loadImage(thumbnailURL, posterImageView: posterImageView) { (thumbnailImage, fromCache) -> Void in
            posterImageView.image = thumbnailImage
            
            if !fromCache {
                fadeIn(posterImageView)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                loadImage(detailedURL, posterImageView: posterImageView) { (detailedImage, fromCache) -> Void in
                    posterImageView.image = detailedImage
                }
            })
        }
    }
    
    static func loadImage(urlString:String, posterImageView:UIImageView, callBack: (dynamicImage:UIImage, fromCache:Bool) -> Void) {
        let urlRequest = NSURLRequest(URL: NSURL(string: urlString)!)
        posterImageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (urlRequest:NSURLRequest, httpURLResponse:NSHTTPURLResponse?, image:UIImage) -> Void in
            callBack(dynamicImage: image, fromCache: httpURLResponse == nil)
            
            }) { (urlRequest:NSURLRequest, httpURLResponse:NSHTTPURLResponse?, error:NSError) -> Void in
//             print(error)
        }
    }
    
    static func fadeIn(view:UIImageView) {
        view.alpha = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            view.alpha = 1
        }
    }

}