//
//  DataUnsafeBytesExtension.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Data {
    func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            try body(rawBufferPointer.bindMemory(to: ContentType.self).baseAddress!)
        }
    }
}
