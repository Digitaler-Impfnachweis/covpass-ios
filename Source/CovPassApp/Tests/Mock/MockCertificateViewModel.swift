//
//  MockCertificateViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

class MockCertificateViewModel: CertificatesOverviewViewModelProtocol {
    // MARK: - Test Variables

    var refreshedCalled = false
    var processCalled = false
    var configureCalled = false
    var selectedCertificateIndex: Int?

    // MARK: - CertificateViewModel

    weak var delegate: CertificatesOverviewViewModelDelegate?

    var addButtonImage: UIImage? = UIImage()

    var certificateViewModels: [CardViewModel] = []

    func refresh() {
        refreshedCalled = true
    }

    func process(payload _: String, completion _: ((Error) -> Void)?) {
        processCalled = true
    }

    func updateTrustList() {}

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

    func detailViewModel(_: ExtendedCBORWebToken) -> CertificateDetailViewModel? {
        return nil
    }

    func detailViewModel(_: IndexPath) -> CertificateDetailViewModel? {
        return nil
    }

    func showCertificate(at _: IndexPath) {
        // TODO: Add tests
    }

    func showCertificate(_: ExtendedCBORWebToken) {
        // TODO: Add tests
    }

    func scanCertificate(withIntroduction _: Bool) {
        // TODO: Add tests
    }

    func showAppInformation() {
        // TODO: Add tests
    }

    func showErrorDialog() {
        // TODO: Add tests
    }
}
