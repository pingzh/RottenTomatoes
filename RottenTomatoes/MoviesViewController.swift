//
//  MoviesCollectionViewController.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/23/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var layout : UICollectionViewFlowLayout!
    
    
    let cellHeight : CGFloat = 250
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cellWidth = _calcCellWidth(self.view.frame.size)
        layout.itemSize = CGSizeMake(cellWidth, cellHeight)
        
        self._getMoviesInfoFromRottenTomatoes()
    
    }
    
    
    
    func _getMoviesInfoFromRottenTomatoes() {
        let requestUrl = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        Alamofire.request(.GET, requestUrl).responseJSON { response in
                if response.response?.statusCode == 200 {
                    if let json = response.result.value {
                        let moviesData = JSON(json)["movies"]
                        for (_, subJson): (String, JSON) in moviesData {
                            let movie = Movie()
                            
                            //TODO change implementation here, not use variable, put them in constructor
                            movie.title = subJson["title"].stringValue
                            movie.runtime = subJson["runtime"].stringValue
                            
                            let ratings = subJson["ratings"]
                            movie.audienceScore = ratings["audience_score"].stringValue
                            movie.criticsScore = ratings["critics_rating"].stringValue
                            
                            let imageUrls = subJson["posters"]
                            movie.lowResImageUrl = self._thumbnailImageUrl(imageUrls["thumbnail"].stringValue)
                            movie.highResImageUrl = self._originalImageUrl(imageUrls["original"].stringValue)
                            
                            Images.downloadThumbnailImage(movie.lowResImageUrl)
                            
                            self.movies.append(movie)
                        }
                        self.collectionView.reloadData()
                    }
                }
                else {
                    Helper.sendAlert("Oops", message: "Sorry, we cannot connect to Rotten Tomatoes!")
                }
        }
        
    }

    func _thumbnailImageUrl(imageUrl: String) -> String {
        return imageUrl
    }
    
    func _originalImageUrl(imageUrl: String) -> String {
        let range = imageUrl.rangeOfString(".*cloudfront.net/", options: NSStringCompareOptions.RegularExpressionSearch)
        let originalImageUrl: String = imageUrl.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")
        return originalImageUrl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //TODO ?? not working!
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            self._getMoviesInfoFromRottenTomatoes()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.movies.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MoviesCell", forIndexPath: indexPath) as! MoviesCollectionViewCell
    
        let movie = self.movies[indexPath.row]
        // Configure the cell
        Alamofire.request(.GET, movie.lowResImageUrl).response() {
            (_, _, data, _) in
            
            let image = UIImage(data: data!)
            cell.moviewImage.image = image
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    func _calcCellWidth(size: CGSize) -> CGFloat {
        let transitionToWide = size.width > size.height
        var cellWidth = size.width / 2
        
        if transitionToWide {
            cellWidth = size.width / 3
        }
        return cellWidth
    }

}
