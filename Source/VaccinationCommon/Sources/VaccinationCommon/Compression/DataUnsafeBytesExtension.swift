//
//  DataUnsafeBytesExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Data {
    func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            try body(rawBufferPointer.bindMemory(to: ContentType.self).baseAddress!)
        }
    }
}
