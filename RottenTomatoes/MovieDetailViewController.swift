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
    
    @IBOutlet weak var audienceScore: UILabel!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var criticsScore: UILabel!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var synopsisTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let refreshControl = UIRefreshControl()
    var downloadingOriginalImage = false
    var selectedMovie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.selectedMovie.title
        self.titleAndYearLabel.text = self.selectedMovie.title + " (" + selectedMovie.year + " )"
        self.criticsScore.text = self.selectedMovie.criticsScore
        self.audienceScore.text = self.selectedMovie.audienceScore
        self.synopsisTextView.text = self.selectedMovie.synopsis
        
        //set scrollView && Zoom scale
        scrollView.contentSize = self.view.bounds.size
        scrollView.delegate = self
        scrollView.indicatorStyle = .Black
        scrollView.minimumZoomScale = 0.25
        scrollView.maximumZoomScale = 2

        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: "_refreshView", forControlEvents: .ValueChanged)
        self.scrollView.addSubview(refreshControl)
        
        self.originalImage.image = Images.imageCache[selectedMovie.lowResImageUrl]
        self._downloadOriginalImage()
    }
    
    //zoom
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.originalImage
    }
    
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
        
        let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 68, width: self.view.bounds.width, height: 10.0))
        progressIndicatorView.tintColor = UIColor.blueColor()
        self.view.addSubview(progressIndicatorView)
        progressIndicatorView.setProgress(0.1, animated: true)
        
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
