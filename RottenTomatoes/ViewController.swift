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

struct StoryBoard {
    static let DetailView = "DetailView"
    static let MovieCell = "MovieCell"
    static let MovieCollectionViewCell = "MovieCollectionViewCell"
}

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkInfoView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentChangeView: UISegmentedControl!
    @IBOutlet weak var tabBar: UITabBar!
    
    var movies = [NSDictionary]()
    var filtered = [NSDictionary]()
    var searchActive = false
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        movies = []

        initControls()
        initDelegateAndDataSource()

        fetchMovies()
        
    }
    
    func initControls () {
        
        self.title = "Movies"
        
        // init refreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        networkInfoView.alpha = 0
        
        segmentChangeView.selectedSegmentIndex = 0
        showViewBasedOnSegmentSelection()
    }
    
    func initDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
    }
    
    // MARK: Actions
    @IBAction func onSegmentValueChanged(sender: AnyObject) {
        showViewBasedOnSegmentSelection()
    }
    
    func showViewBasedOnSegmentSelection() {

        switch segmentChangeView.selectedSegmentIndex
        {
        case 1:
            tableView.hidden = true
            collectionView.hidden = false
        
        default:
            tableView.hidden = false
            collectionView.hidden = true
            
            
        }
        
    }
    
    func fetchMovies(refresh:Bool = false) {
        
        self.showNetworkError(false, animated: false)
        showLoadingIcon(refresh)
        
        API.getMovies(refresh, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func fetchDVD(refresh:Bool = false) {
        self.showNetworkError(false, animated: false)
        showLoadingIcon(refresh)
        
        API.getDVD(refresh, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func showLoadingIcon(refresh:Bool) {
        
        if !refresh {
            // show animation loading icon
            JTProgressHUD.show()
            //
        }
    }
    
    func onSuccess(data:NSData, refresh:Bool) {
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        self.movies = json["movies"] as! [NSDictionary]
        
        self.showNetworkError(false)
        
        self.reloadData()
        
        if refresh {
            self.refreshControl.endRefreshing()
        }
        else {
            JTProgressHUD.hide()
        }
    }
    
    func onFailure(error:NSError, refresh:Bool) {
        self.showNetworkError(true)
        JTProgressHUD.hide()
        if refresh {
            self.refreshControl.endRefreshing()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? DetailViewController {
            let indexPath = sender as! NSIndexPath
            detailViewController.movie = self.movies[indexPath.row]
        }
        
        view.endEditing(true)
    }
    
    func onRefresh() {
        switch tabBar.selectedItem!.tag {
        case 1:
            fetchDVD(true)
        default:
            fetchMovies(true)
        }
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
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 108)
        self.networkInfoView.alpha = 0.85
    }
    
    func hideNetworkInfoView() {
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 64)
        self.networkInfoView.alpha = 0
    }
    
    func reloadData() {
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}

// MARK: Tab Bar
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

// MARK: Search
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
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count == 0
        {
            filtered = movies
        }
        else {
            filtered = movies.filter({ (movie:NSDictionary) -> Bool in
                let title =  "\(movie["title"]!)"
                return title.lowercaseString.containsString(searchText.lowercaseString)
            })
        }
        
        self.reloadData()
    }
}

// MARK: Table View
extension ViewController : UITableViewDelegate, UITableViewDataSource {
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
        
        if searchActive {
            if filtered.count == 0
            {
                return UITableViewCell()
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.MovieCell) as! MovieCell
        let movie = searchActive ? filtered[indexPath.row] : movies[indexPath.row]
        
        cell.updateUI(movie)
        
        return cell
    }
    
    // MARK: - Navigation
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.performSegueWithIdentifier(StoryBoard.DetailView, sender: indexPath)
    }
}

// MARK : Collection View
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        return movies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if movies.count == 0
        {
            return UICollectionViewCell()
        }
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.MovieCollectionViewCell, forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = searchActive ? filtered[indexPath.row] : movies[indexPath.row]
        
        cell.updateUI(movie)
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
//        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! MovieCollectionViewCell
        self.performSegueWithIdentifier(StoryBoard.DetailView, sender: indexPath)
    }
}
