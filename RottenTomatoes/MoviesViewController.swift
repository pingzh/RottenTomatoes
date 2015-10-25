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
    
    @IBOutlet weak var searchMovie: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var layout : UICollectionViewFlowLayout!
    let refreshControl = UIRefreshControl()
    
    let cellHeight : CGFloat = 250
    var movies: [Movie] = []
    var downloadingMovieInfo = false
    var selectedMovie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    Images.invalidAllImageCache()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        let cellWidth = _calcCellWidth(self.view.frame.size)
        layout.itemSize = CGSizeMake(cellWidth, cellHeight)
        
        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: "_refreshView", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
        
        searchMovie.text = nil
        
        _getMoviesInfoFromRottenTomatoes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + collectionView.frame.size.height > scrollView.contentSize.height * 0.8 {
            self._getMoviesInfoFromRottenTomatoes()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MoviesCell", forIndexPath: indexPath) as! MoviesCollectionViewCell
        
        let movie = self.movies[indexPath.row]
        
        cell.moviewImage.image = nil
        Images.downloadThumbnailImage(movie.lowResImageUrl, uiImageView: cell.moviewImage)
        cell.movieName.text = movie.title
        cell.moviewLength.text = movie.runtime + " min"
        cell.movieYear.text = movie.year
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedMovie = movies[indexPath.row]
        self.performSegueWithIdentifier("MoviesToMovieDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MoviesToMovieDetail" {
            let movieDetailView = segue.destinationViewController as! MovieDetailViewController
            movieDetailView.selectedMovie = selectedMovie
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        searchMovie.text = nil
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MoviesCollectionViewCell
        cell.setCellSelected(true, uiImageView: cell.moviewImage)
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MoviesCollectionViewCell
        cell.setCellSelected(false, uiImageView: cell.moviewImage)
    }
    
    func _calcCellWidth(size: CGSize) -> CGFloat {
        let transitionToWide = size.width > size.height
        var cellWidth = size.width / 2
        
        if transitionToWide {
            cellWidth = size.width / 3
        }
        return cellWidth
    }
    
    func _getMoviesInfoFromRottenTomatoes() {
        if downloadingMovieInfo {
            return
        }
        
        let requestUrl = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        downloadingMovieInfo = true
        
        let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 64 + 43.0, width: self.view.bounds.width, height: 10.0))
        progressIndicatorView.tintColor = UIColor.blueColor()
        self.view.addSubview(progressIndicatorView)
        progressIndicatorView.setProgress(0.2, animated: true)
        
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
                                    criticsScore: ratings["critics_score"].stringValue,
                                    year: subJson["year"].stringValue,
                                    synopsis: subJson["synopsis"].stringValue,
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
                    progressIndicatorView.setProgress(0.8, animated: true)
                    Helper.sendAlert("Oops", message: "Sorry, we cannot connect to Rotten Tomatoes!")
                }
                self.downloadingMovieInfo = false
        }
    }
    
    func _originalImageUrl(imageUrl: String) -> String {
        let range = imageUrl.rangeOfString(".*cloudfront.net/", options: NSStringCompareOptions.RegularExpressionSearch)
        let originalImageUrl: String = imageUrl.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")
        return originalImageUrl
    }
    
    func _refreshView() {
        searchMovie.text = nil
        refreshControl.beginRefreshing()
        movies = []
        collectionView!.reloadData()
        _getMoviesInfoFromRottenTomatoes()
        refreshControl.endRefreshing()
    }
    
    func _thumbnailImageUrl(imageUrl: String) -> String {
        return imageUrl
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //searchActive = false;
        self.searchMovie.endEditing(true)
    }
}
