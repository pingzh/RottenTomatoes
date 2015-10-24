//
//  Images.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/23/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Images {
    
    static var imageCache: [String: UIImage] = [:]
    
    static func invalidAllImageCache() {
        self.imageCache = [:]
    }
    
    static func downloadThumbnailImage(imageUrl: String!, uiImageView: UIImageView) {
        
        if let image = self.imageCache[imageUrl] {
            uiImageView.image = image
            print("using cache")
            return
        }
        
        Alamofire.request(.GET, imageUrl).response() {
            (_, _, data, _) in
            let image = UIImage(data: data!)!
            self.imageCache[imageUrl] = image
            
            uiImageView.image = image
        }
        
    }
    
}