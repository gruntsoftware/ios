//
//  CreateZipHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
// Inspired https://medium.com/parable-engineering/how-to-easily-create-zip-files-in-swift-without-third-party-dependencies-a1c36a451ea1

import Swift
import Foundation

enum CreateZipError: Swift.Error {
    case urlNotADirectory(URL)
    case failedToCreateZIP(Swift.Error)
}

func createZip(
    zipFinalURL: URL,
    fromDirectory directoryURL: URL
) throws -> URL {
    // see URL extension below
    guard directoryURL.isDirectory else {
        throw CreateZipError.urlNotADirectory(directoryURL)
    }
    
    var fileManagerError: Swift.Error?
    var coordinatorError: NSError?
    let coordinator = NSFileCoordinator()
    coordinator.coordinate(
        readingItemAt: directoryURL,
        options: .forUploading,
        error: &coordinatorError
    ) { zipCreatedURL in
        do {
            // will fail if file already exists at finalURL
            // use `replaceItem` instead if you want "overwrite" behavior
            try FileManager.default.moveItem(at: zipCreatedURL, to: zipFinalURL)
        } catch {
            fileManagerError = error
        }
    }
    if let error = coordinatorError ?? fileManagerError {
        throw CreateZipError.failedToCreateZIP(error)
    }
    return zipFinalURL
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
