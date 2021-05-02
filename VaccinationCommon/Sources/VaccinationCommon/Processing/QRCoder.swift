//
//  QRCoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR
import PromiseKit

public enum QRCodeError: Error {
    case qrCodeExists
}

public class QRCoder: QRCoderProtocol {
    private let base45Encoder = Base45Encoder()
    private let cose1SignEncoder = CoseSign1Parser()

    public init() {}

    public func parse(_ payload: String) -> Promise<VaccinationCertificate> {
        return Promise { seal in
            let base45Decoded = try base45Encoder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            let certificate = try JSONDecoder().decode(VaccinationCertificate.self, from: jsonData)
            seal.fulfill(certificate)
        }
    }

    public func parse(_ payload: String) -> Promise<ValidationCertificate> {
        return Promise { seal in
            let base45Decoded = try base45Encoder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            let certificate = try JSONDecoder().decode(ValidationCertificate.self, from: jsonData)
            seal.fulfill(certificate)
        }
    }
}
