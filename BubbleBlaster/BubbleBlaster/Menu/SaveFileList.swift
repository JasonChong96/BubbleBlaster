//
//  SaveFileList.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Encapsulates the list of save files for the level chooser in order to
/// support deletion without the controller directly manipulating storage.
struct SaveFileList {
    static let empty: SaveFileList = SaveFileList()

    var savedFileNames: [String]

    init?(isLoadFromStorage: Bool) {
        self.init()

        if isLoadFromStorage {
            guard let savedFileNames = StorageManager.getAllSaveFileNames() else {
                return nil
            }

            self.savedFileNames = savedFileNames
        }
    }

    private init() {
        self.savedFileNames = []
    }

    /// Checks if the save file with the given file name is deletable.
    ///
    /// - Parameter name: The name of the file
    /// - Returns: true if the file is deletable, false if not.
    static func isDeletionAllowed(for name: String) -> Bool {
        return !StorageManager.isPresetLevel(fileName: name)
    }

    /// Deletes the saved file at matching the input name
    ///
    /// - Parameter index: The name of the file to delete.
    /// - Returns: true if the deletion is successful, false if not
    mutating func deleteFile(named name: String) -> Bool {
        if !StorageManager.removeFile(named: name) {
            return false
        }

        savedFileNames = savedFileNames.filter { $0 != name }
        return true
    }
}
