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

public enum QRCodeError: Error, ErrorCode {
    case qrCodeExists
    case versionNotSupported
    case warningCountOfCertificates
    case errorCountOfCertificatesReached

    public var errorCode: Int {
        switch self {
        case .qrCodeExists:
            return 201
        case .versionNotSupported:
            return 202
        case .warningCountOfCertificates:
            return 203
        case .errorCountOfCertificatesReached:
            return 204
        }
    }
}

enum QRCoder {
    static func parse(_ payload: String) -> Promise<CoseSign1Message> {
        return Promise { seal in
            let payload = payload.stripPrefix()
            let base45Decoded = try Base45Coder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            let cosePayload = try CoseSign1Message(decompressedPayload: decompressedPayload)
            seal.fulfill(cosePayload)
        }
    }
}
