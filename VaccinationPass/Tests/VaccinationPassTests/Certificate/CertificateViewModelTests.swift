//
//  CertificateViewModelTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
@testable import VaccinationPass
import VaccinationUI
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
        let nib = UIConstants.bundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}
