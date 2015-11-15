//
//  DetailViewController.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/10/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var audienceRating: UILabel!
    @IBOutlet weak var criticsRating: UILabel!
    @IBOutlet weak var synopsis: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var filmNameLabel: UILabel!
    
    var movie:NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _movie = movie {
            
            let thumbnailURL = _movie.valueForKeyPath("posters.thumbnail") as! String
            let detailedURL = _movie.valueForKeyPath("posters.detailed") as! String
            let audienceRatingScore = _movie.valueForKeyPath("ratings.audience_score") as! Int
            let criticsRatingScore = _movie.valueForKeyPath("ratings.critics_score") as! Int
            let releaseDate = _movie["release_dates"]!["theater"]!!
            let runtime = _movie.valueForKey("runtime") as! Int

            self.audienceRating.text = "\(audienceRatingScore)% liked it"
            self.criticsRating.text = "\(criticsRatingScore)%"
            self.synopsis.text = "\(_movie["synopsis"]!)"
            self.synopsis.sizeToFit()
            self.releaseDateLabel.text = "\(releaseDate)"
            self.runtimeLabel.text = "\(runtime) minutes"
            self.title = movie!["title"] as? String
            self.filmNameLabel.text = self.title
            
            ImageManager.loadPosters(thumbnailURL, detailedURL: detailedURL, posterImageView: self.posterImageView)
        }
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
        
        self.scrollView.frame = self.view.bounds;
        self.scrollView.contentSize.height = self.synopsis.frame.origin.y + self.synopsis.frame.height + 10;
    }

}
