//
//  StorageManager.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import FileProvider
import UIKit

/// Encapsulates utility methods that are related to storage of save files. Cannot be instantiated.
enum StorageManager {
    private static let presetFolder = "Presets"
    private static let fileExtension = "json"

    /// Saves an object that conforms to the `Encodable` protocol as a file with the given name and
    /// json extension in the Documents directory.
    ///
    /// - Parameters:
    ///     - object: The object to save.
    ///     - name: The name to save the object as.
    static func save<T: Encodable>(object: T, as name: String) throws {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = urls.first else {
            return
        }

        let fileName = name + ".\(fileExtension)"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
    }

    /// Gets all save file names in the Documents directory.
    ///
    /// - Returns: An array of all the names of save files stored.
    static func getAllSaveFileNames() -> [String]? {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = urls.first else {
            return nil
        }
        guard let files = try? FileManager.default.contentsOfDirectory(at: documentDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsSubdirectoryDescendants) else {
            return nil
        }

        let filenames = files.filter { $0.pathExtension == fileExtension }
            .map { $0.lastPathComponent.replacingOccurrences(of: ".\(fileExtension)", with: "")}
            .filter { !$0.hasSuffix(GameConstants.imageSuffix) }

        return filenames
    }

    /// Removes the file with the input name
    ///
    /// - Parameter fileName: The name of the file to remove.
    /// - Returns: true if the removal is a success, false if not.
    static func removeFile(named fileName: String) -> Bool {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = urls.first else {
            return false
        }

        let suffixes = [".\(fileExtension)", "\(GameConstants.imageSuffix).\(fileExtension)"]
        var deleted = false

        for suffix in suffixes {
            let url = documentDirectory.appendingPathComponent("\(fileName)\(suffix)")
            do {
                try FileManager.default.removeItem(at: url)
                deleted = true
            } catch {
            }
        }

        return deleted
    }

    /// Loads the preview image for the save file with the given name.
    ///
    /// - Returns: the preview UIImage for the save file with the given name. If the loading fails for any reason,
    ///     returns nil
    static func loadPreviewImage(named name: String) -> UIImage? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentDirectory = urls.first else {
            return nil
        }

        let fileName = "\(name)\(GameConstants.imageSuffix).\(fileExtension)"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            return nil
        }

        let decoder = JSONDecoder()
        guard let image = try? decoder.decode(UIImageCodableWrapper.self, from: data).image else {
            return nil
        }

        return image
    }

    /// Copies pre-packaged levels into the documents folder.
    static func copyPresetsIntoFolder() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: ".\(fileExtension)", subdirectory: nil) else {
            return
        }

        // Get the URL of the Documents Directory
        let documentUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = documentUrls.first else {
            return
        }
        guard let documentFiles = try? FileManager.default.contentsOfDirectory(at: documentDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsSubdirectoryDescendants).map({ $0.lastPathComponent }) else {
                return
        }

        for url in urls {
            let fileName = url.lastPathComponent
            if documentFiles.contains(fileName) {
                continue
            }

            guard let contents = try? Data(contentsOf: url) else {
                continue
            }

            try? contents.write(to: documentDirectory.appendingPathComponent(fileName), options: .atomic)
        }
    }

    /// Checks if any preset levels match the input file name
    ///
    /// - Parameter fileName: The name of the file to check.
    /// - Returns: true if the input saved file name matches a preset level, false if not.
    static func isPresetLevel(fileName: String) -> Bool {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: ".\(fileExtension)", subdirectory: nil) else {
            return false
        }

        return urls.map { $0.lastPathComponent }
            .contains("\(fileName).\(fileExtension)")
    }

    /// Loads and decodes the save file with the input name.
    ///
    /// - Parameter name: The name of the save file to load
    ///
    /// - Returns: The decoded save file as a `GameCells` instance.
    static func loadSaveFile(named name: String) throws -> GameStatePersistant {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentDirectory = urls.first else {
            throw LoadError.directoryError("Document directory not found")
        }

        let fileName = name + ".json"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        if let data = FileManager.default.contents(atPath: fileURL.path) {
            let decoder = JSONDecoder()
            let gameCells = try decoder.decode(GameStatePersistant.self, from: data)
            return gameCells
        } else {
            throw LoadError.fileNotFound("\(name) does not exist.")
        }
    }
}
