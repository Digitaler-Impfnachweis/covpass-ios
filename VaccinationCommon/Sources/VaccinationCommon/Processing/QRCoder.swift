//
//  QRCoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR

public enum QRCodeError: Error {
    case qrCodeExists
}

public class QRCoder: QRCoderProtocol {
    private let base45Encoder = Base45Encoder()
    private let cose1SignEncoder = CoseSign1Parser()

    public init() {}

    public func parse(_ payload: String, completion: ((Error) -> Void)?) -> VaccinationCertificate? {
        do {
            let base45Decoded = try base45Encoder.decode(payload)
            let decompressedPayload = Compression.decompress(Data(base45Decoded)) ?? Data()
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            return try JSONDecoder().decode(VaccinationCertificate.self, from: jsonData)
        } catch {
            completion?(error)
            return nil
        }
    }
}
