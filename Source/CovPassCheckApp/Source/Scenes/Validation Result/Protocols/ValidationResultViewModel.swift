//
//  ValidationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct Paragraph {
    var icon: UIImage?
    var title: String
    var subtitle: String
}

typealias ValidationResultViewModel = ValidationViewModel & CancellableViewModelProtocol

protocol ResultViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidChange(_ newViewModel: ValidationResultViewModel)
}

protocol ValidationViewModel {
    var router: ValidationResultRouterProtocol { get set }
    var repository: VaccinationRepositoryProtocol { get set }
    var certificate: CBORWebToken? { get set }
    var delegate: ResultViewModelDelegate? { get set }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    func scanNextCertifcate()
}

extension ValidationViewModel {
    func cancel() {
        router.showStart()
    }

    func scanNextCertifcate() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.checkCertificate($0)
        }
        .done { certificate in
            let vm = ValidationResultFactory.createViewModel(
                router: self.router,
                repository: self.repository,
                certificate: certificate,
                error: nil
            )
            self.delegate?.viewModelDidChange(vm)
        }
        .catch { error in
            let vm = ValidationResultFactory.createViewModel(
                router: self.router,
                repository: self.repository,
                certificate: nil,
                error: error
            )
            self.delegate?.viewModelDidChange(vm)
        }
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }
}
