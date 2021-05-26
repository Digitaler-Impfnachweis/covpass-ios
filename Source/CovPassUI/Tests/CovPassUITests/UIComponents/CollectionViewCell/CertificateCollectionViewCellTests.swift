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

        XCTAssertEqual(sut.containerView.layoutMargins, .init(top: .space_30, left: .space_24, bottom: .space_30, right: .space_24))
        XCTAssertEqual(sut.containerView.tintColor, .brandAccent)
        XCTAssertEqual(sut.containerView.layer.cornerRadius, 14)

        XCTAssertEqual(sut.contentStackView.customSpacing(after: sut.actionView), .space_20)
    }

    func testLayoutSubviews() {
        sut.layoutSubviews()

        XCTAssertEqual(sut.contentView.layer.shadowPath, UIBezierPath(roundedRect: sut.containerView.frame, cornerRadius: sut.containerView.layer.cornerRadius).cgPath)
    }

    func testUpdateViews() {
        sut.viewModelDidUpdate()

        XCTAssertEqual(sut.containerView.backgroundColor, viewModel?.backgroundColor)
        XCTAssertEqual(sut.headerView.subtitleLabel.attributedText, viewModel.title.styledAs(.body).colored(viewModel.tintColor))
        XCTAssertEqual(sut.headerView.tintColor, viewModel.tintColor)
        XCTAssertEqual(sut.headerView.buttonImage, UIImage.starFull.withRenderingMode(.alwaysTemplate))
        XCTAssertEqual(sut.headerView.buttonTint, viewModel.tintColor)
        XCTAssertEqual(sut.contentStackView.customSpacing(after: sut.headerView), .space_12)

        XCTAssertEqual(sut.qrContainerView.image, viewModel.qrCode)
        XCTAssertEqual(sut.qrContainerView.layoutMargins, .init(top: .space_20, left: .zero, bottom: .space_20, right: .zero))
        XCTAssertFalse(sut.qrContainerView.isHidden)
        XCTAssertEqual(sut.qrContainerView.titleLabel.attributedText, viewModel.qrCodeTitle?.styledAs(.body).colored(.onBackground70).aligned(to: .center))
        XCTAssertFalse(sut.qrContainerView.titleLabel.isHidden)

        XCTAssertEqual(sut.titleView.textableView.attributedText, viewModel.name.styledAs(.header_1).colored(viewModel.tintColor))
        XCTAssertEqual(sut.titleView.backgroundColor, .clear)
        XCTAssertEqual(sut.contentStackView.customSpacing(after: sut.titleView), .space_12)

        XCTAssertEqual(sut.actionView.stateImageView.image, viewModel.actionImage)
        XCTAssertEqual(sut.actionView.titleLabel.attributedText, viewModel.actionTitle.styledAs(.header_3).colored(viewModel.tintColor))
        XCTAssertEqual(sut.actionView.stateImageView.tintColor, viewModel.tintColor)
        XCTAssertEqual(sut.actionView.actionButton.tintColor, viewModel.tintColor)
        XCTAssertEqual(sut.actionView.tintColor, .neutralWhite)
    }

    // MARK: - Mock Data

    private func createQrCertificateCell() -> CertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(CertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? CertificateCollectionViewCell
    }
}
