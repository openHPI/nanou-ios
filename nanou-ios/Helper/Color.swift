//
//  Color.swift
//  nanou-ios
//
//  Created by Max Bothe on 05/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

extension UIColor {

    class var nanouOrange: UIColor {
        return UIColor(red: 241.0/255.0, green: 133.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }

    class var nanouPink: UIColor {
        return UIColor(red: 233.0/255.0, green: 68.0/255.0, blue: 117.0/255.0, alpha: 1.0)
    }

}


extension CAGradientLayer {

    class func nanouGradientLayer(frame: CGRect, reverse: Bool = false) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.nanouOrange.cgColor, UIColor.nanouPink.cgColor]
        if reverse {
            gradient.colors?.reverse()
        }
        return gradient
    }

    class func gradientLayer(frame: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors
        return gradient
    }

}

extension UIImage {

    class func onboardingGradient(frame: CGRect) -> UIImage? {
        let colors = [UIColor.white.cgColor]
        let gradientLayer = CAGradientLayer.gradientLayer(frame: frame, colors: colors)

        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage
    }

}
