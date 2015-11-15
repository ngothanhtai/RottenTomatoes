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
    var listRefreshControl:UIRefreshControl!
    var gridRefreshControl:UIRefreshControl!
    
    var currentDataTask:NSURLSessionDataTask?
    
    // MARK: Enumerations
    enum Tab : Int {
        case BoxOffice = 0
        case DVD = 1
        
        var description:String {
            get {
                switch self {
                case .BoxOffice:
                    return "Box Office"
                case .DVD:
                    return "DVD"
                }
            }
        }
    }
    
    enum ViewStyle:Int {
        case List = 0
        case Grid = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        movies = []

        initControls()
        initDelegateAndDataSource()

        fetchData(Tab.BoxOffice)
        
    }
    
    func initControls () {
        
        self.navigationController?.navigationBar.barStyle = .Black;
        
        listRefreshControl = UIRefreshControl()
        listRefreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        self.tableView.insertSubview(listRefreshControl, atIndex: 0)
        gridRefreshControl = UIRefreshControl()
        gridRefreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        self.collectionView.insertSubview(gridRefreshControl, atIndex: 0)
        
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
        
        listRefreshControl.endRefreshing()
        gridRefreshControl.endRefreshing()
        
        let viewStyle = ViewStyle(rawValue: segmentChangeView.selectedSegmentIndex)!
        switch viewStyle
        {
        case ViewStyle.Grid:
            tableView.hidden = true
            collectionView.hidden = false
            
            refreshControl = gridRefreshControl

        case ViewStyle.List:
            tableView.hidden = false
            collectionView.hidden = true
            
            refreshControl = listRefreshControl
        }
        
    }
    
    func fetchData(tab:Tab, refresh:Bool = false) {
        
        if(currentDataTask != nil)
        {
            currentDataTask?.cancel()
        }
        
        if !refresh {
            // show animation loading icon
            JTProgressHUD.show()
            //
        }
        
        self.showNetworkError(false, animated: false)
        
        switch tab {
        case Tab.BoxOffice:
            currentDataTask = API.getMovies(refresh, onSuccess: onSuccess, onFailure: onFailure)
        case Tab.DVD:
            currentDataTask = API.getDVD(refresh, onSuccess: onSuccess, onFailure: onFailure)
        }
        
    }
    
    func onSuccess(data:NSData, refresh:Bool) {
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        self.movies = json["movies"] as! [NSDictionary]
        self.filtered = self.movies
        
        self.showNetworkError(false)
        
        self.reloadData()
        
        if refresh {
            self.refreshControl.endRefreshing()
        }
        else {
            JTProgressHUD.hide()
        }
        
        searchBar.text = ""
        self.title = Tab.init(rawValue: tabBar.selectedItem!.tag)?.description
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
        let tab = Tab.init(rawValue: tabBar.selectedItem!.tag)!
        fetchData(tab, refresh: true)
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
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 44)
        self.networkInfoView.alpha = 0.65
    }
    
    func hideNetworkInfoView() {
        self.networkInfoView.frame.origin = CGPoint(x: self.networkInfoView.frame.origin.x, y: 0)
        self.networkInfoView.alpha = 0
    }
    
    func reloadData() {
        self.tableView.reloadData()
        self.collectionView.reloadData()
        
        self.tableView.setContentOffset(CGPointZero, animated: false)
        self.collectionView.setContentOffset(CGPointZero, animated: false)
    }
}

// MARK: Tab Bar
extension ViewController : UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let tab = Tab.init(rawValue: item.tag)!
        fetchData(tab)
    }
}

// MARK: Search
extension ViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
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
        
        return filtered.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if filtered.count == 0
        {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.MovieCell) as! MovieCell
        let movie = filtered[indexPath.row]
        
        cell.updateUI(movie)
        
        let selectedBG = UIView()

        selectedBG.backgroundColor = UIColor(colorLiteralRed: 164.0/255.0, green: 218.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = selectedBG
        
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
        return filtered.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if filtered.count == 0
        {
            return UICollectionViewCell()
        }
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.MovieCollectionViewCell, forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = filtered[indexPath.row]
        
        cell.updateUI(movie)
        
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor(colorLiteralRed: 164.0/255.0, green: 218.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        self.performSegueWithIdentifier(StoryBoard.DetailView, sender: indexPath)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.whiteColor()
        }
        
    }
}
