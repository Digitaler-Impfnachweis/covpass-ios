//
//  CertificateCollectionViewCellTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import Foundation
import XCTest

class CertificateCollectionViewCellTests: XCTestCase {
    // MARK: - Test Variables

    var sut: CertificateCollectionViewCell!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = createQrCertificateCell()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    // MARK: - Mock Data

    private func createQrCertificateCell() -> CertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(CertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? CertificateCollectionViewCell
    }
}
