//
//  CertificateRevocationRepository.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public struct CertificateRevocationRepository: CertificateRevocationRepositoryProtocol {
    private typealias KIDList = Void
    private let client: CertificateRevocationDataSourceProtocol

    public init(client: CertificateRevocationDataSourceProtocol) {
        self.client = client
    }

    public func isRevoked(_ webToken: ExtendedCBORWebToken) -> Guarantee<Bool> {
        do {
            let parameters = try RevocationParameters(webToken)
            return isRevoked(parameters).recover { _ in .value(false) }
        } catch {
            return .value(false)
        }
    }

    private func isRevoked(_ parameters: RevocationParameters) -> Promise<Bool> {
        client
            .getKIDList()
            .then { response -> Promise<Bool> in
                let kid = parameters.kid
                guard response.contains(kid) else { return .value(false) }
                let counts = response.hashTypeCounts(kid)
                return self.getIndexList(parameters, counts)
            }
    }

    private func getIndexList(_ parameters: RevocationParameters, _ hashTypesCountMap: [(CertificateRevocationHashType, Int)]) -> Promise<Bool> {
        guard let hashType = hashTypesCountMap.first?.0 else {
            return .value(false)
        }
        let kid = parameters.kid
        let byte1 = parameters.hash(for: hashType)[0]
        let byte2 = parameters.hash(for: hashType)[1]
        return client
            .headIndexList(kid: kid, hashType: hashType)
            .then { _ in self.client.getIndexList(kid: kid, hashType: hashType) }
            .then { response -> Promise<Bool> in
                if response.contains(byte1, byte2) {
                    return self.getChunkList(parameters, hashType: hashType)
                }
                return self.getIndexList(
                    parameters,
                    Array(hashTypesCountMap.dropFirst())
                )
            }
    }

    private func getChunkList(_ parameters: RevocationParameters, hashType: CertificateRevocationHashType) -> Promise<Bool> {
        let kid = parameters.kid
        let hash = Array(parameters.hash(for: hashType).prefix(16))
        let byte1 = hash[0]
        let byte2 = hash[1]
        var chunkListResponse1: CertificateRevocationChunkListResponse?

        return firstly {
            client.headChunkList(kid: kid, hashType: hashType, byte1: byte1, byte2: nil)
        }
        .then {
            self.client.getChunkList(kid: kid, hashType: hashType, byte1: byte1, byte2: nil)
        }
        .then { response -> Promise<Void> in
            chunkListResponse1 = response
            return self.client.headChunkList(kid: kid, hashType: hashType, byte1: byte1, byte2: byte2)
        }
        .then {
            self.client.getChunkList(kid: kid, hashType: hashType, byte1: byte1, byte2: byte2)
        }
        .then { chunkListResponse2 -> Promise<Bool> in
            guard let chunkListResponse1 = chunkListResponse1 else {
                assertionFailure("Must never happen.")
                return .init(error: ApplicationError.unknownError)
            }
            let isRevoked = chunkListResponse1.hashes.contains(hash) ||
                chunkListResponse2.hashes.contains(hash)

            return .value(isRevoked)
        }
    }
}

private struct RevocationParameters {
    let kid: KID
    private let hashes: [CertificateRevocationHashType: CertificateRevocationHash]
    init(_ token: ExtendedCBORWebToken) throws {
        let message = try token.coseSign1Message()
        let dgc = token.vaccinationCertificate.hcert.dgc
        let signatureHash = message.revocationSignatureHash
        let uciHash = dgc.revocationUCIHash
        let countryUCIHash = dgc.revocationUCICountryHash
        guard signatureHash.count > 15, uciHash.count > 15, countryUCIHash.count > 15 else {
            throw CertificateRevocationRepositoryError.token
        }

        kid = message.keyIdentifier
        hashes = [
            .signature: signatureHash,
            .uci: uciHash,
            .countryCodeUCI: countryUCIHash
        ]
    }

    func hash(for type: CertificateRevocationHashType) -> CertificateRevocationHash {
        hashes[type]!
    }
}
