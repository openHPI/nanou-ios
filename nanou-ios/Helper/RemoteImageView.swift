//
//  RemoteImageView.swift
//  nanou-ios
//
//  Created by Max Bothe on 31/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {

    func loadFrom(_ urlString: String?, orShow placeholder: String) {
        let label = UILabel(frame: self.frame)
        label.text = placeholder
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center

        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placerholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let url = URL(string: urlString ?? "")
        self.sd_setImage(with: url, placeholderImage: placerholderImage)
    }

}
