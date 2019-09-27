//
//  ViewController+SaveFileName.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

extension LevelDesignerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }

        return ((textField.text?.count ?? 0) + string.count) <= GameConstants.maxSaveFileNameLength &&
            string.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeState(to: .normal)

        guard let name = textField.text,
            !name.isEmpty else {
            showGenericAlert(titled: "Error", withMsg: "File name must not be empty")
            return false
        }

        if getGameCellsController().isEmpty() {
            showGenericAlert(titled: "All cells are empty", withMsg: "You cannot save an empty game!")
            return false
        }

        if StorageManager.isPresetLevel(fileName: name) {
            showGenericAlert(titled: "You cannot overwrite a preset level!", withMsg: "Please try a different name.")
            return false
        }

        guard (try? getGameCellsController().saveModel(as: name)) != nil else {
            showGenericAlert(titled: "Error", withMsg: "Failed to save file. Please try again")
            return false
        }
        saveImage(as: name)
        textField.text = ""
        showGenericAlert(titled: "Success!", withMsg: "Successfully saved \(name)")
        reloadSaveFiles()
        return true
    }
}
