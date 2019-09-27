//
//  NumShootersPickerDelegate.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 26/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Data source and delegate for the number of shooters picker.
class NumShootersPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let options = [Int](1...2)
    var changedPickerCallback: ((Int) -> Void)?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(options[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changedPickerCallback?(options[row])
    }
}
