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
    let refreshControl = UIRefreshControl()
    
    let cellHeight : CGFloat = 250
    var movies: [Movie] = []
    var downloadingMovieInfo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        let cellWidth = _calcCellWidth(self.view.frame.size)
        layout.itemSize = CGSizeMake(cellWidth, cellHeight)
        
        refreshControl.tintColor = UIColor.blueColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
        
        self._getMoviesInfoFromRottenTomatoes()
    }
    
    
    func handleRefresh() {
        refreshControl.beginRefreshing()
        
        // Reset the model
        movies = []
        //self.currentPage = 1
        
        // Refresh the UI
        self.collectionView!.reloadData()
        
        // We have our own spinner
        refreshControl.endRefreshing()
        
        _getMoviesInfoFromRottenTomatoes()
    }
    
    func _getMoviesInfoFromRottenTomatoes() {
        if self.downloadingMovieInfo {
            return
        }
        
        let requestUrl = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        self.downloadingMovieInfo = true
        
        let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 64 + 43.0, width: self.view.bounds.width, height: 10.0))
        progressIndicatorView.tintColor = UIColor.blueColor()
        self.view.addSubview(progressIndicatorView)
        
        Alamofire.request(.GET, requestUrl)
            .progress { (_, totalBytesRead, totalBytesExpectedToRead) in
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                    progressIndicatorView.setProgress(progress, animated: true)
                    
                    if totalBytesRead == totalBytesExpectedToRead {
                        progressIndicatorView.removeFromSuperview()
                    }
                }
            }
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        var newMovieInfos: [Movie] = []
                        if let json = response.result.value {
                            let moviesData = JSON(json)["movies"]
                            for (_, subJson): (String, JSON) in moviesData {
                                let ratings = subJson["ratings"]
                                let imageUrls = subJson["posters"]
                                let movie = Movie(
                                    title: subJson["title"].stringValue,
                                    runtime: subJson["runtime"].stringValue,
                                    audienceScore: ratings["audience_score"].stringValue,
                                    criticsScore: ratings["critics_rating"].stringValue,
                                    year: subJson["year"].stringValue,
                                    thumbnail: self._thumbnailImageUrl(imageUrls["thumbnail"].stringValue),
                                    original: self._originalImageUrl(imageUrls["original"].stringValue)
                                )
                                newMovieInfos.append(movie)
                            }
                            
                            let lastItem = self.movies.count
                            self.movies.appendContentsOf(newMovieInfos)
                            let indexPaths = (lastItem..<self.movies.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                progressIndicatorView.removeFromSuperview()
                                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                            }
                        }
                    }
                }
                else {
                    Helper.sendAlert("Oops", message: "Sorry, we cannot connect to Rotten Tomatoes!")
                }
                self.downloadingMovieInfo = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    TODO ?? not working!
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + collectionView.frame.size.height > scrollView.contentSize.height * 0.8 {
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
        
        Images.downloadThumbnailImage(movie.lowResImageUrl, uiImageView: cell.moviewImage)
        
        cell.movieName.text = movie.title
        cell.moviewLength.text = movie.runtime
        cell.movieRattings.text = movie.audienceScore
        
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
    
    
    func _thumbnailImageUrl(imageUrl: String) -> String {
        return imageUrl
    }
    
    func _originalImageUrl(imageUrl: String) -> String {
        let range = imageUrl.rangeOfString(".*cloudfront.net/", options: NSStringCompareOptions.RegularExpressionSearch)
        let originalImageUrl: String = imageUrl.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")
        return originalImageUrl
    }
    
    
    func _calcCellWidth(size: CGSize) -> CGFloat {
        let transitionToWide = size.width > size.height
        var cellWidth = size.width / 2
        
        if transitionToWide {
            cellWidth = size.width / 3
        }
        return cellWidth
    }
    
}
