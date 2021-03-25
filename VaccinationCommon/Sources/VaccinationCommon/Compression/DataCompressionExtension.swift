//
//  DataCompressionExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Compression

public extension Data {
    /// Compresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: compressed data
    func compress(withAlgorithm algo: CompressionAlgorithm) -> Data? {
         withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            Compression.perform((operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB), source: sourcePtr, sourceSize: count)
        }
    }
    
    /// Decompresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: decompressed data
    func decompress(withAlgorithm algo: CompressionAlgorithm) -> Data? {
        withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            Compression.perform((COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB), source: sourcePtr, sourceSize: count)
        }
    }
}
