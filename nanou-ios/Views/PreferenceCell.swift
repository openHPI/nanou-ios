//
//  PreferenceCell.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

class PreferenceCell: UITableViewCell {

    weak var delegate: PreferenceCellDelegate?
    @IBOutlet var weightSlider: UISlider!

    @IBAction func preferenceWeightChanged(_ sender: UISlider) {
        self.delegate?.cell(self, didChangeValue: sender.value)
    }

}

protocol PreferenceCellDelegate: class {
    func cell(_ cell: PreferenceCell, didChangeValue value: Float)
}
