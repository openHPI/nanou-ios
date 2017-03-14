//
//  VideoCell.swift
//  nanou-ios
//
//  Created by Max Bothe on 27/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import TagListView

class VideoCell: UICollectionViewCell {

    weak var delegate: VideoCellDelegate?

    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var providerLabel: UILabel!
    @IBOutlet var tags: TagListView!
    @IBOutlet var licenseButton: UIButton!

    @IBAction func tapDismiss(_ sender: Any) {
        self.delegate?.didDismiss(cell: self)
    }

    @IBAction func tapAccept(_ sender: Any) {
        self.delegate?.didSelect(cell: self)
    }

    @IBAction func tapLicense(_ sender: Any) {
        self.delegate?.didTapLicense(cell: self)
    }

}

protocol VideoCellDelegate: class {
    func didSelect(cell: VideoCell)
    func didDismiss(cell: VideoCell)
    func didTapLicense(cell: VideoCell)
}
