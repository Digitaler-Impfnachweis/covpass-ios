//
//  DataCompressionExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation
import PromiseKit

public extension Data {
    /// Compresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: compressed data
    func compress(withAlgorithm _: CompressionAlgorithm) -> Data? {
        withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            Compression.perform((operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB), source: sourcePtr, sourceSize: count)
        }
    }

    /// Decompresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: decompressed data
    func decompress(withAlgorithm _: CompressionAlgorithm) -> Data? {
        withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            Compression.perform((COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB), source: sourcePtr, sourceSize: count)
        }
    }

    /// Promise for compressed data.
    var compressed: Promise<Data> {
        Promise { seal in
            if let data = compress(withAlgorithm: .zlib) {
                seal.fulfill(data)
            } else {
                seal.reject(Compression.Error())
            }
        }
    }

    /// Promise for decompressed data.
    var decompressed: Promise<Data> {
        Promise { seal in
            if let data = Compression.decompress(self) {
                seal.fulfill(data)
            } else {
                seal.reject(Compression.Error())
            }
        }
    }
}
