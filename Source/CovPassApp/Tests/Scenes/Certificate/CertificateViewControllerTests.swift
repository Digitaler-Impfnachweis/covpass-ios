//
//  CertificateViewControllerTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassApp
import CovPassUI
import XCTest

class CertificateViewControllerTests: XCTestCase {
    // MARK: - Test Variables

    var sut: CertificatesOverviewViewController!
    var viewModel: MockCertificateViewModel!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        viewModel = MockCertificateViewModel()
        sut = CertificatesOverviewViewController(viewModel: viewModel)
        // Load View
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut
    }

    override func tearDown() {
        viewModel = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    func testCollectionView() {
        XCTAssertNotNil(sut.collectionView.delegate)
        XCTAssertNotNil(sut.collectionView.dataSource)
    }

    func testSetupActionButton() {
        XCTAssertNotNil(sut.addButton.action)
    }
}
