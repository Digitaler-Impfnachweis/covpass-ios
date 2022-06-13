//
//  PDFCBORExtractor.swift
//  
//
//  Created by Thomas Kuleßa on 08.06.22.
//

import Foundation
import PromiseKit

public struct PDFCBORExtractor: PDFCertificateExtractorProtocol {
    private let maximalNumberOfTokens: Int
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let document: QRCodePDFDocumentProtocol
    private let coseSign1MessageConverter: CoseSign1MessageConverterProtocol
    private let existingTokens: [ExtendedCBORWebToken]
    private let queue: DispatchQueue

    public init(
        document: QRCodePDFDocumentProtocol,
        maximalNumberOfTokens: Int,
        existingTokens: [ExtendedCBORWebToken],
        coseSign1MessageConverter: CoseSign1MessageConverterProtocol,
        revocationRepository: CertificateRevocationRepositoryProtocol,
        queue: DispatchQueue
    ) {
        self.document = document
        self.maximalNumberOfTokens = maximalNumberOfTokens
        self.existingTokens = existingTokens
        self.coseSign1MessageConverter = coseSign1MessageConverter
        self.revocationRepository = revocationRepository
        self.queue = queue
    }

    func extract() -> Promise<PDFCertificateExtractorResults> {
        Promise { seal in
            queue.async {
                var results = PDFCertificateExtractorResults()
                var pageNumber = 1

                while pageNumber <= document.numberOfPages && results.count < maximalNumberOfTokens {
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

    private func extendedCBORWebTokens(_ qrCodes: [String]) -> Guarantee<PDFCertificateExtractorResults> {
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
