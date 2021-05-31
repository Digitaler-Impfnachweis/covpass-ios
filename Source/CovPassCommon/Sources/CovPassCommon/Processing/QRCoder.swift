//
//  QRCoder.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation
import PromiseKit
import SwiftCBOR

public enum QRCodeError: Error {
    case qrCodeExists
    case versionNotSupported
}

public class QRCoder: QRCoderProtocol {
    private let base45Encoder = Base45Coder()
    private let cose1SignParser = CoseSign1Parser()
    private let cert = HCert()

    /// The current supported digital green certificate model version
    var supportedDGCVersion = "1.0.0"

    public init() {}

    public func parse(_ payload: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            let payload = payload.stripPrefix()
            let base45Decoded = try base45Encoder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            let cosePayload = try cose1SignParser.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignParser.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            let certificate = try JSONDecoder().decode(CBORWebToken.self, from: jsonData)

            if !certificate.hcert.dgc.isSupportedVersion {
                throw QRCodeError.versionNotSupported
            }

            seal.fulfill(certificate)
        }
    }
}
