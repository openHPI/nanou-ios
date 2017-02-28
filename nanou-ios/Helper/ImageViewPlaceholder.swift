//
//  ImageViewPlaceholder.swift
//  nanou-ios
//
//  Created by Max Bothe on 28/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit

extension UIImageView {

    func show(placeholder: String) {
        let label = UILabel(frame: self.frame)
        label.text = placeholder
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.center

        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.image = placeholderImage
    }

}
