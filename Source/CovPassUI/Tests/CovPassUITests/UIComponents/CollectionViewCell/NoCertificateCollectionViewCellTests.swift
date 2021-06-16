//
//  NoCertificateCollectionViewCellTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import Foundation
import XCTest

class NoCertificateCollectionViewCellTests: XCTestCase {
    // MARK: - Test Variables

    var sut: NoCertificateCollectionViewCell!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = createNoCertificateCell()
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

    private func createNoCertificateCell() -> NoCertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}
