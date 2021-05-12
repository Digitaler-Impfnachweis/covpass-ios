//
//  CertificateCollectionViewCellTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
@testable import VaccinationUI
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
