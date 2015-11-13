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
    var indexPath:NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let _movie = movie {
            ImageManager.loadPosters(_movie.valueForKeyPath("posters.thumbnail") as! String, detailedURL: _movie.valueForKeyPath("posters.detailed") as! String, indexPath: indexPath!, posterImageView: self.posterImageView)
            self.audienceRating.text = "\(_movie["ratings"]!["audience_score"]!!)%"
            self.criticsRating.text = "\(_movie["ratings"]!["critics_score"]!!)%"
            self.synopsis.text = "\(_movie["synopsis"]!)"
            
            self.title = movie!["title"] as? String
        }
    }

}
