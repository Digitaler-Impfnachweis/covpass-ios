//
//  ValidatorViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit
import VaccinationCommon
import PromiseKit

public class ValidatorViewModel {
    
    // MARK: - Private

    private let router: ValidatorRouterProtocol
    private let parser: QRCoder = QRCoder()
    
    // MARK: - Internal
    
    var title: String { "Prüf-App" }
    
    var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], icon: .chevronRight)
    }

    public func process(payload: String) -> Promise<ValidationCertificate> {
        return Promise<ValidationCertificate>() { seal in
            // TODO refactor parser
            guard let decodedPayload: ValidationCertificate = parser.parse(payload, completion: { error in
                seal.reject(error)
            }) else {
                seal.reject(ApplicationError.unknownError)
                return
            }
            seal.fulfill(decodedPayload)
        }
    }
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)

    // MARK: - Lifecycle

    public init(router: ValidatorRouterProtocol) {
        self.router = router
    }

    func startQRCodeValidation() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.process(payload: $0)
        }
        .done {
            self.router.showCertificate($0)
        }
        .cauterize()
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }
}
