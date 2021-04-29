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
    private let cert = HCert()

    public init() {}

    public func parse(_ payload: String, completion: ((Error) -> Void)?) -> VaccinationCertificate? {
        do {
            let base45Decoded = try base45Encoder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                completion?(ApplicationError.general("Could not decompress QR Code data"))
                return nil
            }
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
//            let cborDecodedProtected = try CBOR.decode(cosePayload?.protected ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            if let cosePayload = cosePayload {
                cert.verify(message: cosePayload)
            }
//            cose1SignEncoder.parse(header: cborDecodedProtected)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            return try JSONDecoder().decode(VaccinationCertificate.self, from: jsonData)
        } catch {
            completion?(error)
            return nil
        }
    }
}
