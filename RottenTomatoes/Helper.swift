//
//  Helper.swift
//  RottenTomatoes
//
//  Created by Ping Zhang on 10/23/15.
//  Copyright © 2015 Ping Zhang. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func sendAlert(title: String, message: String) {
        let alertView: UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
}