//
//  Segues.swift
//  nanou-ios
//
//  Created by Max Bothe on 24/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

class SegueFromLeft: UIStoryboardSegue {

    override func perform() {
        self.source.view.superview?.insertSubview(self.destination.view, aboveSubview: self.source.view)
        self.destination.view.transform = CGAffineTransform(translationX: self.source.view.frame.size.width, y: 0)

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                           self.destination.view.transform = CGAffineTransform(translationX: 0, y: 0)
                       },
                       completion: { finished in
                           self.source.present(self.destination, animated: false, completion: nil)
                       }
        )
    }

}
