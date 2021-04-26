//
//  File.swift
//  
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import XCTest
import VaccinationUI
@testable import VaccinationPass


class CertificateViewModelTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: DefaultCertificateViewModel<MockQRCoder>!
    var sutDelegate: MockViewModelDelegate!

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = DefaultCertificateViewModel(parser: MockQRCoder())
        sutDelegate = MockViewModelDelegate()
        sut.delegate = sutDelegate
    }

    override func tearDown() {
        sut = nil
        sutDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
//    func testProcessQr() {
//        try! sut.process(payload: NSUUID().uuidString)
//        XCTAssertTrue(sutDelegate.updateCalled)
//    }
    
    func testHeadline() {
        XCTAssertEqual(sut.headlineTitle, "Übersicht aller Impfnachweise")
        XCTAssertEqual(sut.headlineButtonInsets, UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0))
        XCTAssertEqual(sut.headlineFont, UIConstants.Font.subHeadlineFont)
        XCTAssertEqual(sut.headlineButtonImage, UIImage(named: UIConstants.IconName.HelpIcon, in: UIConstants.bundle, compatibleWith: nil))
    }
    
    func testAddButtonImage() {
        XCTAssertEqual(sut.addButtonImage, UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil))
    }
    
    func testReuseIdentifier() {
        let item = MockCellConfiguration.noCertificateConfiguration()
        sut.certificates = [item]
        let identifer = sut.reuseIdentifier(for: IndexPath(row: 0, section: 0))
        XCTAssertEqual(identifer, item.identifier)
    }
    
    func testConfigure() {
        let item = MockCellConfiguration.noCertificateConfiguration()
        sut.certificates = [item]
        guard let cell = createNoCertificateCell() else {
            XCTFail("Unable to create cell \(NoCertificateCollectionViewCell.self) fom nib")
            return
        }
        sut.configure(cell: cell, at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(cell.headlineLabel.text, "Title")
        XCTAssertEqual(cell.subHeadlineLabel.text, "Subtitle")
    }
    
    // MARK: - Mock Data
    
    private func createNoCertificateCell() -> NoCertificateCollectionViewCell? {
        let nib = UIConstants.bundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}

