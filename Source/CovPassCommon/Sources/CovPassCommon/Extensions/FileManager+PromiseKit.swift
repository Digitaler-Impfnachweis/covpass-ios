//
//  FileManager+PromiseKit.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public struct FileManagerError: Error {}

public extension FileManager {
    func createDirectoryPromise(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]? = nil
    ) -> Promise<Void> {
        do {
            try createDirectory(
                at: url,
                withIntermediateDirectories: createIntermediates,
                attributes: attributes
            )
        } catch  {
            return .init(error: error)
        }
        return .value
    }

    func createFilePromise(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey : Any]? = nil
    ) -> Promise<Void> {
        guard createFile(atPath: path, contents: data, attributes: attr) else {
            return .init(error: FileManagerError())
        }
        return .value
    }
}
