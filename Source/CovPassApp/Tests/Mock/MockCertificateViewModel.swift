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
    var isLoading: Bool = false

    // MARK: - CertificateViewModel

    weak var delegate: CertificatesOverviewViewModelDelegate?
    var addButtonImage: UIImage? = UIImage()
    var hasCertificates: Bool = false
    var accessibilityAddCertificate = "addCertificate"
    var accessibilityMoreInformation = "moreInformation"
    var openingAnnouncment = "announcement"
    var closingAnnouncment: String = "closingannouncement"
    var showMultipleCertificateHolder = true
    var informationTitle: String = ""
    var informationCopy: String = ""
    var addButtonIsHidden: Bool = false
    var moreButtonTitle: String = "MEHR"

    func moreButtonTapped() {}

    func handleOpen(url _: URL) -> Bool {
        true
    }

    func updateBoosterRules() {}

    func refresh() -> Promise<Void> {
        refreshedCalled = true
        return .value
    }

    func process(payload _: String, completion _: ((Error) -> Void)?) {
        processCalled = true
    }

    func updateTrustList() {}

    func updateValueSets() {}

    func reuseIdentifier(for _: IndexPath) -> String {
        "reuseIdentifier"
    }

    var headlineTitle: String {
        "Title"
    }

    var headlineButtonImage: UIImage? {
        nil
    }

    func loadCertificates() {}

    func process(payload _: String) -> Promise<ExtendedCBORWebToken> {
        Promise(error: ApplicationError.unknownError)
    }

    func detailViewModel(_: ExtendedCBORWebToken) -> CertificateDetailViewModel? {
        nil
    }

    func detailViewModel(_: IndexPath) -> CertificateDetailViewModel? {
        nil
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

    func showNotificationsIfNeeded() {}

    func viewModel(for _: Int) -> CardViewModel {
        NoCertificateCardViewModel()
    }

    func countOfCells() -> Int {
        0
    }

    func revokeIfNeeded() {}
}
