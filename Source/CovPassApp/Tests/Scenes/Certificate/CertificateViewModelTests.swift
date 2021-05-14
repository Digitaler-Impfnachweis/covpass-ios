//
//  CertificateViewModelTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassApp
import CovPassUI
import XCTest

class CertificateViewModelTests: XCTestCase {
    // MARK: - Test Variables

    var sut: DefaultCertificateViewModel!
    var sutDelegate: MockCertificateViewModelDelegate!
    var sceneCoordinator: SceneCoordinatorMock!
    var router: CertificateRouter!
    var repository: VaccinationRepositoryMock!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sceneCoordinator = SceneCoordinatorMock()
        router = CertificateRouter(sceneCoordinator: sceneCoordinator)
        repository = VaccinationRepositoryMock()
        sut = DefaultCertificateViewModel(router: router, repository: repository)
        sutDelegate = MockCertificateViewModelDelegate()
        sut.delegate = sutDelegate
    }

    override func tearDown() {
        sut = nil
        sutDelegate = nil
        router = nil
        sceneCoordinator = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    // MARK: - Mock Data

    private func createNoCertificateCell() -> NoCertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}
