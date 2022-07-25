//
//  FileManagerMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

class FileManagerMock: FileManager {
    private(set) var removeItemCalledWithURL: URL?
    private(set) var createDirectoryCalledWithURL: URL?
    private(set) var createFileCalledWithParameters: [(path: String, contents: Data?)] = []
    private(set) var contentsCalledWithPath: String?
    private(set) var fileExistsCalledWithPath: String?
    var contents: Data?
    var error: Error?
    var createFileSuccess = true
    var fileExistsSuccess = true

    override func removeItem(at url: URL) throws {
        removeItemCalledWithURL = url
        if let error = error {
            throw error
        }
    }

    override func contents(atPath path: String) -> Data? {
        contentsCalledWithPath = path
        return contents
    }

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]? = nil) -> Bool {
        createFileCalledWithParameters.append((path, data))
        return createFileSuccess
    }

    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createDirectoryCalledWithURL = url
        if let error = error {
            throw error
        }
    }

    override func fileExists(atPath path: String) -> Bool {
        fileExistsCalledWithPath = path
        return fileExistsSuccess
    }
}
