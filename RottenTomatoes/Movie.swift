//
//  Movie.swift
//  RottenTomatoes
//
//  Created by Ngo Thanh Tai on 11/11/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation
import EVReflection
class Movie : EVObject {
    var id:String?
    var year:String?
    var title:String?
    var synopsis:String?
    var posters:Poster?
    var ratings:Rating?
}

class Poster : EVObject {
    var thumbnail:String?
    var detailed:String?
}

class Rating : EVObject {
    var critics_score:String?
    var critics_rating:String?
    var audience_score:String?
    var audience_rating:String?
}
