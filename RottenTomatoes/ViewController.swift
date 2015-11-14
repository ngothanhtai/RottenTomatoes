//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/9/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit
import EVReflection
import JTProgressHUD

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkInfoView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    var movies = [NSDictionary]!()
    var refreshControl:UIRefreshControl!
    
    var searchActive = false
    var filtered = [NSDictionary]()
    
    struct StoryBoard {
        static let DetailView = "DetailView"
    }
    
    let boxOfficeAPI = "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214"
    let dvdAPI = "https://coderschool-movies.herokuapp.com/dvds?api_key=xja087zcvxljadsflh214"

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
        
        searchBar.delegate = self

        
        movies = []
        
        networkInfoView.alpha = 0
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]

        fetchMovies()
        
    }
    
    func fetchMovies(refresh:Bool = false) {
        
        self.showNetworkError(false, animated: false)
        if !refresh {
            // show animation loading icon
            
            JTProgressHUD.showWithStyle(.Gradient)
            //
        }

        let url = NSURL(string: boxOfficeAPI)
        let sesson = NSURLSession.sharedSession()
        let task = sesson.dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard error == nil else {
                print("Error \(error)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    self.showNetworkError(true)
                    JTProgressHUD.hide()
                    if refresh {
                        self.refreshControl.endRefreshing()
                    }
                })
                
                return
            }
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
            
            self.movies = json["movies"] as! [NSDictionary]
            
//            var setMovies = Set<Movie>()
//            for itemMovie in self.movies {
//                let movie = Movie(dictionary: itemMovie)
//                setMovies.insert(movie)
//            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.showNetworkError(false)
                
                self.tableView.reloadData()
                
                if refresh {
                    self.refreshControl.endRefreshing()
                }
                else {
                    JTProgressHUD.hide()
                }
            })
        }
        task.resume()
    }
    
    func fetchDVD(refresh:Bool = false) {
        
        self.showNetworkError(false, animated: false)
        if !refresh {
            // show animation loading icon
            JTProgressHUD.show()
            //
        }
        
        let url = NSURL(string: dvdAPI)
        let sesson = NSURLSession.sharedSession()
        let task = sesson.dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard error == nil else {
                print("Error \(error)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.showNetworkError(true)
                    JTProgressHUD.hide()
                    if refresh {
                        self.refreshControl.endRefreshing()
                    }
                })
                
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
                
                self.showNetworkError(false)
                
                self.tableView.reloadData()
                
                if refresh {
                    self.refreshControl.endRefreshing()
                }
                else {
                    JTProgressHUD.hide()
                }
            })
        }
        task.resume()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive {
            return filtered.count
        }
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if movies.count == 0
        {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("movieCell") as! MovieCell
        let movie = searchActive ? filtered[indexPath.row] : movies[indexPath.row]
        
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
            detailViewController.movie = self.movies[indexPath.row]
        }
    }
    
    func onRefresh() {
        fetchMovies(true)
    }
    
    func showNetworkError(show:Bool, animated:Bool = true) {
        if show {
            if animated {
                UIView.animateWithDuration(0.5, animations: showNetworkInfoView)
            } else {
                showNetworkInfoView()
            }
            
        } else {
            if animated {
                UIView.animateWithDuration(0.5, animations: hideNetworkInfoView)
            } else {
                hideNetworkInfoView()
            }
            
        }
    }
    
    func showNetworkInfoView() {
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 64)
        self.networkInfoView.alpha = 0.85
    }
    
    func hideNetworkInfoView() {
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 24)
        self.networkInfoView.alpha = 0
    }
}


extension ViewController : UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        switch item.tag
        {
            case 0:
                fetchMovies()
            case 1:
                fetchDVD()
            default:
                fetchMovies()
        }
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = movies.filter({ (movie:NSDictionary) -> Bool in
            let title =  "\(movie["title"]!)"
            return title.lowercaseString.containsString(searchText.lowercaseString)
        })
        
        self.tableView.reloadData()
        
        if (searchText.characters.count == 0)
        {
            searchBar.resignFirstResponder()
        }
    }
}
