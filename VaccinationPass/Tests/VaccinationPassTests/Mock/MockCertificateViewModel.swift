//
//  MockCertificateViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import VaccinationCommon
@testable import VaccinationPass
import VaccinationUI

class MockCertificateViewModel: CertificateViewModel {
    // MARK: - Test Variables

    var processCalled = false
    var configureCalled = false

    // MARK: - CertificateViewModel

    weak var delegate: CertificateViewModelDelegate?

    var addButtonImage: UIImage? = UIImage()

    var certificateViewModels: [CardViewModel] = []

    func process(payload _: String, completion _: ((Error) -> Void)?) {
        processCalled = true
    }

    func reuseIdentifier(for indexPath: IndexPath) -> String {
        certificateViewModels[indexPath.row].reuseIdentifier
    }

    var headlineTitle: String {
        "Title"
    }

    var headlineButtonImage: UIImage? {
        nil
    }

    func loadCertificates() {
        certificateViewModels = [MockCardViewModel()]
    }

    func process(payload _: String) -> Promise<ExtendedCBORWebToken> {
        return Promise(error: ApplicationError.unknownError)
    }

    func detailViewModel(_: ExtendedCBORWebToken) -> VaccinationDetailViewModel? {
        return nil
    }

    func detailViewModel(_: IndexPath) -> VaccinationDetailViewModel? {
        return nil
    }

    func showCertificate(at _: IndexPath) {
        // TODO: Add tests
    }

    func showCertificate(_: ExtendedCBORWebToken) {
        // TODO: Add tests
    }

    func scanCertificate() {
        // TODO: Add tests
    }

    func showAppInformation() {
        // TODO: Add tests
    }

    func showErrorDialog() {
        // TODO: Add tests
    }
}
