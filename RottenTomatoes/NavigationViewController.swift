//
//  NavigationViewController.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/25/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add Groupon Green to navigationBar
        let grouponGreen = UIColor(red: 120/255, green: 181/255, blue: 72/255, alpha: 1)
        self.navigationBar.barTintColor = grouponGreen
        self.navigationItem.rightBarButtonItem?.tintColor = grouponGreen
        self.navigationBar.tintColor = UIColor.whiteColor()
        //self.navigationItem.rightBarButtonItem.c
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
}
