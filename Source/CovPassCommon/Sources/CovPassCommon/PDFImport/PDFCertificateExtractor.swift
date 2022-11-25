//
//  PDFCBORExtractor.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public final class PDFCBORExtractor: CertificateExtractorProtocol {
    private let maximalNumberOfTokens: Int
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let coseSign1MessageConverter: CoseSign1MessageConverterProtocol
    private var existingTokens: [ExtendedCBORWebToken] = []
    private let queue: DispatchQueue

    public init(
        maximalNumberOfTokens: Int,
        coseSign1MessageConverter: CoseSign1MessageConverterProtocol,
        revocationRepository: CertificateRevocationRepositoryProtocol,
        queue: DispatchQueue
    ) {
        self.maximalNumberOfTokens = maximalNumberOfTokens
        self.coseSign1MessageConverter = coseSign1MessageConverter
        self.revocationRepository = revocationRepository
        self.queue = queue
    }

    public func extract(document: QRCodeDocumentProtocol, ignoreTokens: [ExtendedCBORWebToken]) -> Promise<CertificateExtractorResults> {
        Promise { seal in
            queue.async { [self] in
                var results = CertificateExtractorResults()
                var pageNumber = 1
                existingTokens = ignoreTokens

                while pageNumber <= document.numberOfPages, results.count < maximalNumberOfTokens {
                    do {
                        let qrCodes = try document.qrCodes(on: pageNumber)
                        let tokens = extendedCBORWebTokens(Array(qrCodes)).wait()
                        for token in tokens {
                            if results.count >= maximalNumberOfTokens {
                                break
                            }
                            results.appendIfNotAlreadyExist(token)
                        }
                        pageNumber += 1
                    } catch {
                        seal.reject(error)
                    }
                }

                seal.fulfill(results)
            }
        }
    }

    private func extendedCBORWebTokens(_ qrCodes: [String]) -> Guarantee<CertificateExtractorResults> {
        Guarantee { seal in
            let iterator = qrCodes.map(validExtendedCBORWebToken).makeIterator()
            when(fulfilled: iterator, concurrently: 2)
                .map { $0.compactMap { $0 } }
                .done { tokens in
                    seal(tokens)
                }
                .catch { _ in
                    seal([])
                }
        }
    }

    private func validExtendedCBORWebToken(from qrCode: String) -> Guarantee<ExtendedCBORWebToken?> {
        Guarantee { seal in
            self.coseSign1MessageConverter
                .convert(message: qrCode)
                .then(tokenDoesNotAlreadyExist)
                .then(tokenIsNotRevoked)
                .done { token in
                    seal(token)
                }
                .catch { _ in
                    seal(nil)
                }
        }
    }

    private func tokenIsNotRevoked(_ token: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        Promise { seal in
            revocationRepository
                .isRevoked(token)
                .done { isRevoked in
                    if isRevoked {
                        seal.reject(CertificateRevocationRepositoryError.token)
                    } else {
                        seal.fulfill(token)
                    }
                }
        }
    }

    private func tokenDoesNotAlreadyExist(_ token: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        guard !existingTokens.contains(token) else {
            return .init(error: PDFCBORConverterError())
        }
        return .value(token)
    }
}

private extension Array where Element == ExtendedCBORWebToken {
    mutating func appendIfNotAlreadyExist(_ token: ExtendedCBORWebToken) {
        if !contains(token) {
            append(token)
        }
    }
}
