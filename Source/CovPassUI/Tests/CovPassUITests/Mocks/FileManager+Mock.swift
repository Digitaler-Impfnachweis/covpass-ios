//
//  File.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

class FileManagerMock: FileManager {
    let removeItemExpectation = XCTestExpectation(description: "removeItem")
    var error: Error?
    var removeItemURL: URL?

    override func removeItem(at url: URL) throws {
        try? super.removeItem(at: url)
        removeItemURL = url
        removeItemExpectation.fulfill()
        if let error = error {
            throw error
        }
    }
}
