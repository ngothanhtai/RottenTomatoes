//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/9/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit
import EVReflection

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]!()
    var refreshControl:UIRefreshControl!
    
    struct StoryBoard {
        static let DetailView = "DetailView"
    }
    
    let dataURL = "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Movies"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init refreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchMovies()
        
    }
    
    func fetchMovies(refresh:Bool = false) {
        movies = []
        
        let url = NSURL(string: dataURL)
        let sesson = NSURLSession.sharedSession()
        let task = sesson.dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard error == nil else {
                print("Error \(error)")
                return
            }
            
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
            
//            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            
            self.movies = json["movies"] as! [NSDictionary]
            
            //var _movies = [Movie](json: NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            var setMovies = Set<Movie>()
            for itemMovie in self.movies {
                let movie = Movie(dictionary: itemMovie)
                setMovies.insert(movie)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                
                if refresh {
                    self.refreshControl.endRefreshing()
                }
            })
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if movies.count == 0
        {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("movieCell") as! MovieCell
        let movie = movies[indexPath.row]
        
        cell.updateUI(movie, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Navigation
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.performSegueWithIdentifier(StoryBoard.DetailView, sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? DetailViewController {
            let indexPath = sender as! NSIndexPath
            detailViewController.indexPath = indexPath
            detailViewController.movie = self.movies[indexPath.row]
        }
    }
    
    func onRefresh() {
        fetchMovies(true)
    }
}

