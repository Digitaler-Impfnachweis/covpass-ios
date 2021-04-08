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

    public init() {}

    public func parse(_ payload: String) { //-> String {
        let base45Decoded = (try? base45Encoder.decode(payload)) ?? []
        print("Base45 Decoded: \(base45Decoded)")
        let base45Encoded = base45Encoder.encode(base45Decoded)
        print("Base45 works fine: \(base45Encoded == payload)")
        let decompressedPayload = decompress(Data(base45Decoded)) ?? Data()
        print("Decompressed payload: \(decompressedPayload)")
        let cosePayload = CodeSign1Encoder.parse(decompressedPayload)
        print("COSE batshit: \(String(describing: cosePayload))")
        let cborDecodedPayload = CBOR.decode(cosePayload?.payload ?? [])

        print("God help us with: \(String(describing: cborDecodedPayload))")
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
