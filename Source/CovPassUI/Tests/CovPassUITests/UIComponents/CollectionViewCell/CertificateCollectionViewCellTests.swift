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
    var viewModel: CertificateCardViewModelProtocol!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = createQrCertificateCell()
        viewModel = CertificateCardViewModelMock()
        sut.viewModel = viewModel
    }

    override func tearDown() {
        viewModel = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testAwakeFromNib() {
        XCTAssertFalse(sut.contentView.clipsToBounds)
        XCTAssertEqual(sut.contentView.layer.shadowColor, UIColor.neutralBlack.cgColor)
        XCTAssertEqual(sut.contentView.layer.shadowRadius, 16)
        XCTAssertEqual(sut.contentView.layer.shadowOpacity, Float(0.2))
        XCTAssertEqual(sut.contentView.layer.shadowOffset, .init(width: 0, height: -4))

        XCTAssertEqual(sut.containerView.layoutMargins, .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8))
        XCTAssertEqual(sut.containerView.tintColor, .brandAccent)
        XCTAssertEqual(sut.containerView.layer.cornerRadius, 26)
    }

    func testLayoutSubviews() {
        sut.layoutSubviews()
        XCTAssertEqual(sut.contentView.layer.shadowPath, UIBezierPath(roundedRect: sut.containerView.frame, cornerRadius: sut.containerView.layer.cornerRadius).cgPath)
    }

    func testUpdateViews() {
        sut.viewModelDidUpdate()
        XCTAssertEqual(sut.containerView.backgroundColor, viewModel?.backgroundColor)
        XCTAssertEqual(sut.qrContainerView.image, viewModel.qrCode)
        XCTAssertEqual(sut.qrContainerView.layoutMargins, .init(top: .zero, left: .zero, bottom: .space_18, right: .zero))
        XCTAssertFalse(sut.qrContainerView.isHidden)
        XCTAssertFalse(sut.qrContainerView.titleLabel.isHidden)
        XCTAssertEqual(sut.titleView.backgroundColor, .clear)
    }

    // MARK: - Mock Data

    private func createQrCertificateCell() -> CertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(CertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? CertificateCollectionViewCell
    }
}
