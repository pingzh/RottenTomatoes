//
//  Movie.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/23/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import Foundation
import UIKit

class Movie {
    var title: String!
    var runtime: String!
    
    var audienceScore: String!
    var criticsScore: String!
    var year: String!
    
    var lowResImageUrl: String!
    var highResImageUrl: String!
    
    init(title: String, runtime: String, audienceScore: String, criticsScore: String, year: String, thumbnail: String, original: String) {
        self.title = title
        self.runtime = runtime
        self.audienceScore = audienceScore
        self.criticsScore = criticsScore
        self.year = year
        self.lowResImageUrl = thumbnail
        self.highResImageUrl = original
    }
    
    
}