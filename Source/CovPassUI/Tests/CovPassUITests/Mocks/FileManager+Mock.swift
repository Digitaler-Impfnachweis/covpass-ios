//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 10.03.22.
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
