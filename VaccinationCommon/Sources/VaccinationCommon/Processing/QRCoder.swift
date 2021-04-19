//
//  QRCoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR

public class QRCoder: QRCoderProtocol {
    private let base45Encoder = Base45Encoder()
    private let cose1SignEncoder = CoseSign1Parser()

    public init() {}

    public func parse(_ payload: String, completion: ((Error) -> Void)?) -> String? {
        do {
            let base45Decoded = try base45Encoder.decode(payload)
            let decompressedPayload = Compression.decompress(Data(base45Decoded)) ?? Data()
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            return cose1SignEncoder.mapToString(cborObject: cborDecodedPayload)
        } catch {
            completion?(error)
            return nil
        }
    }
}
