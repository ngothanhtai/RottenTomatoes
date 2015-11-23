//
//  API.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/14/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation


class API {
    
    static var currentDataTask:NSURLSessionDataTask?
    struct URL {
        static let boxOffice = "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214"
        static let dvd = "https://coderschool-movies.herokuapp.com/dvds?api_key=xja087zcvxljadsflh214"
    }
    
    static func getMovies(refresh:Bool, onSuccess: (data:NSData, refresh:Bool) -> Void, onFailure: (error:NSError, refresh:Bool) -> Void) -> Void {
        currentDataTask = fetchData(URL.boxOffice, refresh: refresh, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    static func getDVD(refresh:Bool, onSuccess: (data:NSData, refresh:Bool) -> Void, onFailure: (error:NSError, refresh:Bool) -> Void) -> Void {
        currentDataTask = fetchData(URL.dvd, refresh: refresh, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    static func fetchData(apiURL:String, refresh:Bool, onSuccess: (data:NSData, refresh:Bool) -> Void, onFailure: (error:NSError, refresh:Bool) -> Void) -> NSURLSessionDataTask {
        
        if(currentDataTask != nil)
        {
            currentDataTask?.cancel()
        }

        let url = NSURL(string: apiURL)
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 86400)
        //let task = sesson.dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
        
        let task = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard error == nil else {
                print("Error \(error)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    onFailure(error: error!, refresh: refresh)
                })
                
                return
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                onSuccess(data: data!, refresh: refresh)
            })
        }
        task.resume()
        
        return task
    }
}