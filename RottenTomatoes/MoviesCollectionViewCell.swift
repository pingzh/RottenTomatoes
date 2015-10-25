//
//  MoviesCollectionViewCell.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/23/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import UIKit

class MoviesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moviewImage: UIImageView!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var moviewLength: UILabel!
    
    static var grouponCat = UIImage(named: "groupon.jpeg")!
    static var previousUIImage: UIImage = UIImage(named: "groupon.jpeg")!

    func setCellSelected(selected : Bool, uiImageView: UIImageView){
        if selected {
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                MoviesCollectionViewCell.previousUIImage = uiImageView.image!
                uiImageView.image = MoviesCollectionViewCell.grouponCat
                
                }, completion: { (finished: Bool) in
            })
        }else{
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                uiImageView.image = MoviesCollectionViewCell.previousUIImage
                }, completion: { (finished: Bool) in
                    
            })
        }
    }
    
}
