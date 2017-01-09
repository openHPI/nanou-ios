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


class SegueUnwindFromRight: UIStoryboardSegue {

    override func perform() {

        self.source.view.superview?.insertSubview(self.destination.view, aboveSubview: self.source.view)
        self.destination.view.transform = CGAffineTransform(translationX: -self.source.view.frame.size.width, y: 0)

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                           self.destination.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        },
                       completion: { finished in
                            self.destination.dismiss(animated: false, completion: nil)
                        }
        )
    }

}

class SegueFade: UIStoryboardSegue {

    override func perform() {
        self.destination.view.alpha = 0.0
        self.source.view.superview?.insertSubview(self.destination.view, aboveSubview: self.source.view)

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                           self.destination.view.alpha = 1.0
                        },
                       completion: { finished in
                            self.source.present(self.destination, animated: false, completion: nil)
                        }
        )
    }

}

class SegueUnwindFade: UIStoryboardSegue {

    override func perform() {
        UIGraphicsBeginImageContext(self.destination.view.bounds.size)
        self.destination.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let destinationViewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let destinationView = UIImageView(image: destinationViewImage)
        destinationView.alpha = 0.0

        UIApplication.shared.keyWindow?.addSubview(destinationView)

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                            destinationView.alpha = 1.0
                        },
                       completion: { finished in
                            self.destination.dismiss(animated: false) {
                                destinationView.removeFromSuperview()
                            }
                        }
        )
    }

}
