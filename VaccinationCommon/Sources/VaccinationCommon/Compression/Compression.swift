//
//  Compression.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Compression

struct Compression {
    
    typealias Config = (operation: compression_stream_operation, algorithm: compression_algorithm)

    static func perform(_ config: Config, source: UnsafePointer<UInt8>, sourceSize: Int, preload: Data = Data()) -> Data? {
        guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }
        
        let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer { streamBase.deallocate() }
        var stream = streamBase.pointee
        
        let status = compression_stream_init(&stream, config.operation, config.algorithm)
        guard status != COMPRESSION_STATUS_ERROR else { return nil }
        defer { compression_stream_destroy(&stream) }
        
        var result = preload
        var flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
        let blockLimit = 64 * 1024
        var bufferSize = Swift.max(sourceSize, 64)
        
        if sourceSize > blockLimit {
            bufferSize = blockLimit
            if config.algorithm == COMPRESSION_LZFSE && config.operation != COMPRESSION_STREAM_ENCODE   {
                // This fixes a bug in Apples lzfse decompressor. it will sometimes fail randomly when the input gets
                // splitted into multiple chunks and the flag is not 0. Even though it should always work with FINALIZE...
                flags = 0
            }
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        stream.dst_ptr  = buffer
        stream.dst_size = bufferSize
        stream.src_ptr  = source
        stream.src_size = sourceSize
        
        while true {
            switch compression_stream_process(&stream, flags) {
            case COMPRESSION_STATUS_OK:
                guard stream.dst_size == 0 else { return nil }
                result.append(buffer, count: stream.dst_ptr - buffer)
                stream.dst_ptr = buffer
                stream.dst_size = bufferSize
                
                if flags == 0 && stream.src_size == 0 { // part of the lzfse bugfix above
                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
                
            case COMPRESSION_STATUS_END:
                result.append(buffer, count: stream.dst_ptr - buffer)
                return result
                
            default:
                return nil
            }
        }
    }

    static func decompress(_ data: Data) -> Data? {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        guard data.count > 2 else { return nil }
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), data.count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count:read)
        }) as Data
        buffer.deallocate()
        return result
    }
}
