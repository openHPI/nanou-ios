//
//  HistoryCell.swift
//  nanou-ios
//
//  Created by Max Bothe on 14/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import TagListView

class HistoryCell: UITableViewCell {

    weak var delegate: HistoryCellDelegate?


    @IBOutlet var imageview: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var providerLabel: UILabel!
    @IBOutlet var tagListView: TagListView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var licenseButton: UIButton!

    @IBAction func tapLicense(_ sender: Any) {
        self.delegate?.didTapLicense(cell: self)
    }

}

protocol HistoryCellDelegate: class {
    func didTapLicense(cell: HistoryCell)
}
