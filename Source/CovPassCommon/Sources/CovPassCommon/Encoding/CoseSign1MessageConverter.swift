//
//  CoseSign1MessageConverter.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public struct CoseSign1MessageConverter: CoseSign1MessageConverterProtocol {
    private let jsonDecoder: JSONDecoder
    private let trustList: TrustList

    public init(jsonDecoder: JSONDecoder, trustList: TrustList) {
        self.jsonDecoder = jsonDecoder
        self.trustList = trustList
    }

    public func convert(message: String) -> Promise<ExtendedCBORWebToken> {
        message
            .stripPrefix()
            .decodedBase45
            .then(\.decompressed)
            .then(CoseSign1Message.promise)
            .then(verifiedCBORWebToken)
            .map { cborWebToken in
                ExtendedCBORWebToken(
                    vaccinationCertificate: cborWebToken,
                    vaccinationQRCodeData: message
                )
            }
    }

    private func verifiedCBORWebToken(_ coseSign1Message: CoseSign1Message) -> Promise<CBORWebToken> {
        when(fulfilled: cborWebToken(from: coseSign1Message),
             HCert.verifyPromise(message: coseSign1Message, trustList: trustList)
        )
        .then(checkExtendedKeyUsage)
        .then(\.noFraud)
        .then(\.notExpired)
    }

    private func cborWebToken(from coseSign1Message: CoseSign1Message) -> Promise<CBORWebToken> {
        do {
            let json = try coseSign1Message.toJSON()
            return jsonDecoder.decodePromise(json)
        } catch {
            return .init(error: error)
        }
    }

    private func checkExtendedKeyUsage(cborWebToken: CBORWebToken, trustCertificate: TrustCertificate) -> Promise<CBORWebToken> {
        HCert.checkExtendedKeyUsagePromise(
            certificate: cborWebToken,
            trustCertificate: trustCertificate
        )
        .map { cborWebToken }
    }
}
