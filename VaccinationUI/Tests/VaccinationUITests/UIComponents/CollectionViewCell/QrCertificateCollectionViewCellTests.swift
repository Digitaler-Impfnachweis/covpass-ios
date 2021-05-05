//
//  QrCertificateCollectionViewCellTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest
@testable import VaccinationUI

class QrCertificateCollectionViewCellTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: QrCertificateCollectionViewCell!

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

    func testConfigure() {
        let item = MockCellConfiguration.qrCertificateConfiguration()
        sut.configure(with: item)
        XCTAssertEqual(sut.titleView.textableView.text, item.subtitle)
        XCTAssertEqual(sut.headerView.subtitleLabel.text, item.title)
        XCTAssertEqual(sut.headerView.tintColor, item.tintColor)
    }
    
    // MARK: - Mock Data
    
    private func createQrCertificateCell() -> QrCertificateCollectionViewCell? {
        let nib = UIConstants.bundle.loadNibNamed("\(QrCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? QrCertificateCollectionViewCell
    }
}


