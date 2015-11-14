//
//  MovieCollectionViewCell.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/14/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func updateUI(movie:NSDictionary) {
        let title =  "\(movie["title"]!)"
        self.titleLabel.text = title
//        descriptionLabel.text = "\(movie["synopsis"]!)"
        let thumbnailURL = movie.valueForKeyPath("posters.thumbnail") as! String
        let detailedURL = movie.valueForKeyPath("posters.detailed") as! String
        ImageManager.loadPosters(thumbnailURL, detailedURL: detailedURL, posterImageView: self.imgView)
    }
    
}
