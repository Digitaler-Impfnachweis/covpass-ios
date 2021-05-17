//
//  CompressionAlgorithm.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation

/// Please consider the [libcompression documentation](https://developer.apple.com/reference/compression/1665429-data_compression)
/// for further details. Short info:
/// zlib  : Aka deflate. Fast with a good compression rate. Proved itself over time and is supported everywhere.
/// lzfse : Apples custom Lempel-Ziv style compression algorithm. Claims to compress as good as zlib but 2 to 3 times faster.
/// lzma  : Horribly slow. Compression as well as decompression. Compresses better than zlib though.
/// lz4   : Fast, but compression rate is very bad. Apples lz4 implementation often to not compress at all.
public enum CompressionAlgorithm {
    case zlib
    case lzfse
    case lzma
    case lz4
}

// MARK: - lowLevelType

extension CompressionAlgorithm {
    var lowLevelType: compression_algorithm {
        switch self {
        case .zlib: return COMPRESSION_ZLIB
        case .lzfse: return COMPRESSION_LZFSE
        case .lz4: return COMPRESSION_LZ4
        case .lzma: return COMPRESSION_LZMA
        }
    }
}
