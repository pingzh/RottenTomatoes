//
//  MovieDetailViewController.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/24/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import UIKit
import Alamofire

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var selectedMovie: Movie!
    
    @IBOutlet weak var audienceScore: UILabel!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var criticsScore: UILabel!
    @IBOutlet weak var originalImage: UIImageView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //var scrollView = UIScrollView()
    
    let refreshControl = UIRefreshControl()
    var downloadingOriginalImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.selectedMovie.title
        self.titleAndYearLabel.text = self.selectedMovie.title + " (" + selectedMovie.year + " )"
        self.criticsScore.text = self.selectedMovie.criticsScore
        self.audienceScore.text = self.selectedMovie.audienceScore
        
        
        scrollView.contentSize = self.view.bounds.size
        scrollView.delegate = self
        scrollView.indicatorStyle = .Black


        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: "_refreshView", forControlEvents: .ValueChanged)
        self.scrollView.addSubview(refreshControl)
        
        self.originalImage.image = Images.imageCache[selectedMovie.lowResImageUrl]
        self._downloadOriginalImage()
        
        
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView){
//        /* Gets called when user scrolls or drags */
//        scrollView.alpha = 0.50
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
//        /* Gets called only after scrolling */
//        scrollView.alpha = 1
//    }
//    
//    func scrollViewDidEndDragging(scrollView: UIScrollView,
//        willDecelerate decelerate: Bool){
//            scrollView.alpha = 1
//    }
//  
    
    
    func _refreshView() {
        refreshControl.beginRefreshing()
        self.originalImage.image = Images.imageCache[selectedMovie.lowResImageUrl]
        _downloadOriginalImage()
        refreshControl.endRefreshing()
    }
    
    func _downloadOriginalImage() {
        let requestUrl = selectedMovie.highResImageUrl
        if let image = Images.imageCache[requestUrl] {
            Images.imageCache[requestUrl] = image
        }
        
        if downloadingOriginalImage {
            return
        }
        
        
        downloadingOriginalImage = true
        
        let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 80, width: self.view.bounds.width, height: 10.0))
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
            .response() { (_, response, data, _) in
                if response?.statusCode == 200 {
                    let image = UIImage(data: data!)!
                    Images.imageCache[requestUrl] = image
                    
                    self.originalImage.image = image
                    //                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    //
                    //                                dispatch_async(dispatch_get_main_queue()) {
                    //                                    progressIndicatorView.removeFromSuperview()
                    //                                }
                    //                            }
                    //                        }
                }
                else {
                    progressIndicatorView.setProgress(0.8, animated: true)
                    Helper.sendAlert("Oops", message: "Sorry, we cannot connect to Rotten Tomatoes!")
                }
                self.downloadingOriginalImage = false
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
