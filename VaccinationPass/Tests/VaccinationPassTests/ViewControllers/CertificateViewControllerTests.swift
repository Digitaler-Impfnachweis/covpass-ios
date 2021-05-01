//
//  CertificateViewControllerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest
import VaccinationUI
@testable import VaccinationPass


class CertificateViewControllerTests: XCTestCase {
    // MARK: - Test Variables
    
    var sut: CertificateViewController!
    var viewModel: MockCertificateViewModel!
    var router: MockPopupRouter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        viewModel = MockCertificateViewModel()
        router = MockPopupRouter()
        // Create sut
        let certificateViewController = CertificateViewController.createFromStoryboard(bundle: Bundle.module)
        viewModel.delegate = certificateViewController
        certificateViewController.viewModel = viewModel
        certificateViewController.router = router
        sut = certificateViewController
        // Load View
        let window = UIWindow(frame:  UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testDotPageIndicator() {
        XCTAssertNotNil(sut.dotPageIndicator.delegate)
        XCTAssertEqual(sut.dotPageIndicator.numberOfDots, viewModel.certificates.count)
        XCTAssertEqual(sut.dotPageIndicator.isHidden, true)
    }
    
    func testSetupHeaderView() {
        XCTAssertEqual(sut.headerView.attributedTitleText, viewModel.headlineTitle.styledAs(.header_2))
        XCTAssertEqual(sut.headerView.image, viewModel.headlineButtonImage)
    }
    
    func testCollectionView() {
        XCTAssertNotNil(sut.collectionView.delegate)
        XCTAssertNotNil(sut.collectionView.dataSource)
    }
    
    func testSetupActionButton() {
        XCTAssertEqual(sut.addButton.icon, viewModel?.addButtonImage)
        XCTAssertNotNil(sut.addButton.action)
    }
    
    func testReloadData() {
        viewModel.certificates.append(MockCellConfiguration.noCertificateConfiguration())
        sut.result(with: .success("Hello World"))
        XCTAssertEqual(sut.collectionView(sut.collectionView, numberOfItemsInSection: 0), viewModel.certificates.count)
    }
    
//    func testPresentPopup() {
//        sut.addButton.action?()
//        XCTAssertTrue(router.presentPopupCalled)
//    }
    
    func testCellForRow() {
        XCTAssertTrue( sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) is NoCertificateCollectionViewCell)
    }
}
