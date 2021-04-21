//
//  File.swift
//
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import XCTest
@testable import VaccinationUI


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

    func testConfigure() {
        let item = MockCellConfiguration.noCertificateConfiguration()
        sut.configure(with: item)
        XCTAssertEqual(sut.headlineLabel.text, "Title")
        XCTAssertEqual(sut.subHeadlineLabel.text, "Subtitle")
    }
    
    // MARK: - Mock Data
    
    private func createNoCertificateCell() -> NoCertificateCollectionViewCell? {
        let nib = UIConstants.bundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}


