//
//  DetailViewController.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/10/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var audienceRating: UILabel!
    @IBOutlet weak var criticsRating: UILabel!
    @IBOutlet weak var synopsis: UILabel!
    
    var movie:NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _movie = movie {
            
            let thumbnailURL = _movie.valueForKeyPath("posters.thumbnail") as! String
            let detailedURL = _movie.valueForKeyPath("posters.detailed") as! String

            self.audienceRating.text = "\(_movie["ratings"]!["audience_score"]!!)%"
            self.criticsRating.text = "\(_movie["ratings"]!["critics_score"]!!)%"
            self.synopsis.text = "\(_movie["synopsis"]!)"
            
            self.title = movie!["title"] as? String
            
            
            ImageManager.loadPosters(thumbnailURL, detailedURL: detailedURL, posterImageView: self.posterImageView)
        }
    }

}
