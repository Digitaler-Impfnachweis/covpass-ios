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
    var sceneCoordinator: SceneCoordinatorMock!
    var router: CertificateRouter!

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sceneCoordinator = SceneCoordinatorMock()
        router = CertificateRouter(sceneCoordinator: sceneCoordinator)
        sut = DefaultCertificateViewModel(router: router, parser: MockQRCoder())
        sutDelegate = MockViewModelDelegate()
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
    
//    func testProcessQr() {
//        try! sut.process(payload: NSUUID().uuidString)
//        XCTAssertTrue(sutDelegate.updateCalled)
//    }
    
    func testHeadline() {
        XCTAssertEqual(sut.headlineTitle, "Übersicht aller Impfnachweise")
        XCTAssertEqual(sut.headlineButtonImage, .help)
    }
    
    func testAddButtonImage() {
        XCTAssertEqual(sut.addButtonImage, .plus)
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

