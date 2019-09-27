//
//  ControllerUtils.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 27/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Shared general utilities for controller component.
enum ControllerUtils {

    /// Generates a controller for a confirmation alert.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - desc: The description to show in the alert.
    ///   - okAction: The function to call if ok is pressed.
    ///   - cancelAction: The function to call if cancel is pressed.
    /// - Returns: The generated controller.
    static func getConfirmationAlert(title: String, desc: String, okAction: (() -> Void)?, cancelAction: (() -> Void)?)
        -> UIAlertController {
        let confirmationAlert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in okAction?()
        }))
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in cancelAction?()
        }))

        return confirmationAlert
    }

    /// Generates a controller for a generic alert.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The description to show in the alert.
    /// - Returns: The generated controller.
    static func getGenericAlert(titled title: String, withMsg message: String) -> UIAlertController {
        return getGenericAlert(titled: title, withMsg: message, action: nil)
    }

    /// Generates a controller for a generic alert.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The description to show in the alert.
    ///   - action: The function to call when ok is pressed.
    /// - Returns: The generated controller.
    static func getGenericAlert(titled title: String, withMsg message: String, action: (() -> Void)?)
        -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in action?() })

        return alert
    }
}
