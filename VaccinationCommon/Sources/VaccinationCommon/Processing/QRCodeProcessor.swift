//
//  QRCodeProcessor.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

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
        let decompressedPayload = Data(base45Decoded).decompress(withAlgorithm: .zlib) ?? Data()
        print("Decompressed payload: \(decompressedPayload)")
        let cosePayload = CodeSign1Encoder.parse(decompressedPayload)
        print("COSE batshit: \(String(describing: cosePayload))")
        let cborDecodedPayload = CBOR.decode(cosePayload?.payload ?? [])

        print("God help us with: \(String(describing: cborDecodedPayload))")
    }
}
