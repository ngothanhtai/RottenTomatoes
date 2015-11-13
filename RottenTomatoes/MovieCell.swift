//
//  MovieCell.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/9/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var posterImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(movie:NSDictionary, indexPath:NSIndexPath) {
        let message =  "\(movie["title"]!)"
        titleLabel.text = message
        descriptionLabel.text = "\(movie["synopsis"]!)"
        let thumbnailURL = movie.valueForKeyPath("posters.thumbnail") as! String
        let detailedURL = movie.valueForKeyPath("posters.detailed") as! String
        ImageManager.loadPosters(thumbnailURL, detailedURL: detailedURL, indexPath: indexPath, posterImageView: self.posterImageView)
    }
    
}
