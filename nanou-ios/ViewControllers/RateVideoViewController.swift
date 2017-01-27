//
//  RateVideoViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 26/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit

class RateVideoViewController: UIViewController {

    @IBAction func tapWatched(_ sender: Any) {
        log.debug("tapWatched")
        self.dismiss(animated: true, completion: nil)
    }

}
