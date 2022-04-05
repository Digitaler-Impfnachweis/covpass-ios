//
//  RevocationInfoViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import CovPassCommon
import Foundation
import PDFKit

public class RevocationInfoViewModel: RevocationInfoViewModelProtocol {
    public var delegate: ViewModelDelegate?
    public let buttonTitle = "revocation_detail_page_button_text".localized(bundle: .main)
    private(set) public var isGeneratingPDF = false
    public let title = "revocation_detail_page_title".localized(bundle: .main)
    public let enableCreatePDF: Bool
    lazy public var infoItems: [ListContentItem] = [
        .init(transactionNumberTitle, transactionNumber),
        .init(keyIDTitle, keyID),
        .init(countryTitle, country),
        .init(expiryDateTitle, expiryDate),
        .init(issuingDateTitle, issuingDate)
    ]
    private lazy var revocationInfo: RevocationInfo = .init(
        transactionNumber: transactionNumber,
        kid: keyID,
        rValueSignature: rValueSignature,
        issuingCountry: country,
        technicalExpiryDate: expiryDate,
        dateOfIssue: DateUtils.dateString(from: timestampDate)
    )
    private let countryTitle = "revocation_detail_page_country".localized(bundle: .main)
    private let expiryDateTitle = "revocation_detail_page_technical_expiry_date".localized(bundle: .main)
    private let issuingDateTitle = "revocation_detail_page_date_of_issuance".localized(bundle: .main)
    private let keyIDTitle = "revocation_detail_page_key_reference".localized(bundle: .main)
    private let rValueSignatureTitle = "revocation_detail_page_r_value_signature".localized(bundle: .main)
    private let transactionNumberTitle = "revocation_detail_page_transaction_number".localized(bundle: .main)
    private let country: String
    private let timestampDate: Date
    private let expiryDate: String
    private let issuingDate: String
    private let keyID: String
    private let rValueSignature: String
    private let transactionNumber: String
    private let fileManager: FileManager
    private let pdfGenerator: RevocationPDFGeneratorProtocol
    private let resolver: Resolver<Void>
    private let router: RevocationInfoRouterProtocol

    public init(router: RevocationInfoRouterProtocol,
         resolver: Resolver<Void>,
         pdfGenerator: RevocationPDFGeneratorProtocol,
         fileManager: FileManager,
         token: ExtendedCBORWebToken,
         coseSign1Message: CoseSign1Message,
         timestamp: Date)
    {
        let cborWebToken = token.vaccinationCertificate
        let dgc = cborWebToken.hcert.dgc
        let timestampSeconds = String(timestamp.timeIntervalSince1970)
        self.timestampDate = timestamp
        self.country = dgc.country
        self.enableCreatePDF = country.uppercased() == "DE"
        self.expiryDate = DateUtils.dateString(from: cborWebToken.exp)
        self.issuingDate = DateUtils.dateString(from: cborWebToken.iat)
        self.keyID = coseSign1Message.keyIdentifier.toBase64()
        self.rValueSignature = coseSign1Message.rValueSignature.toHexString()
        self.transactionNumber = (keyID + rValueSignature + timestampSeconds).sha256()
        self.pdfGenerator = pdfGenerator
        self.router = router
        self.resolver = resolver
        self.fileManager = fileManager
    }

    public func cancel() {
        resolver.fulfill_()
    }

    public func createPDF() {
        startPDFGeneration()
            .then { self.pdfGenerator.generate(with: self.revocationInfo) }
            .map { pdfDocument in
                RevocationPDFExportData(
                    pdfDocument: pdfDocument,
                    issuingCountry: self.country,
                    transactionNumber: self.transactionNumber,
                    date: self.timestampDate,
                    fileManager: self.fileManager
                )
            }
            .done { exportData in
                self.isGeneratingPDF = false
                self.delegate?.viewModelDidUpdate()
                self.router.showPDFExport(with: exportData)
            }
            .catch { [weak self] error in
                self?.isGeneratingPDF = false
                self?.delegate?.viewModelUpdateDidFailWithError(error)
            }
    }

    private func startPDFGeneration() -> Guarantee<Void> {
        isGeneratingPDF = true
        delegate?.viewModelDidUpdate()
        return .value
    }
}

private extension DateUtils {
    static func dateString(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        return Self.isoDateFormatter.string(from: date)
    }
}

private extension DigitalGreenCertificate {
    var country: String {
        let country: String
        if let v = v?.first {
            country = v.co
        } else if let t = t?.first {
            country = t.co
        } else if let r = r?.first {
            country = r.co
        } else {
            country = ""
        }
        return country
    }
}
