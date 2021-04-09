//
//  QRCodeProcessor.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR

public class QRCodeProcessor {
    private let base45Encoder = Base45Encoder()
    private let cose1SignEncoder = CoseSign1Encoder()

    public init() {}

    public func parse(_ payload: String) -> String? {
        // Error handling to be improved
        do {
            let base45Decoded = try base45Encoder.decode(payload)
            let decompressedPayload = decompress(Data(base45Decoded)) ?? Data()
            let cosePayload = cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            return cose1SignEncoder.mapToString(cborObject: cborDecodedPayload)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func decompress(_ data: Data) -> Data? {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count:read)
        }) as Data
        buffer.deallocate()
        return result
    }
}
