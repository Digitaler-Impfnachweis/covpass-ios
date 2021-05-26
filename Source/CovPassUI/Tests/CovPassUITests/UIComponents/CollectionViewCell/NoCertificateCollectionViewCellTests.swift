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
    var viewModel: NoCertificateCardViewModelProtocol!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        viewModel = NoCertificateCardViewModelMock()
        sut = createNoCertificateCell()
        sut.viewModel = viewModel
    }

    override func tearDown() {
        viewModel = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInit() {
        XCTAssertEqual(sut.containerView.layoutMargins, .init(top: .space_120, left: .space_40, bottom: .space_120, right: .space_40))
        XCTAssertEqual(sut.containerView.layer.cornerRadius, 15)

        XCTAssertEqual(sut.stackView.spacing, .zero)
        XCTAssertEqual(sut.stackView.customSpacing(after: sut.iconImageView), .space_10)
    }

    func testUpdateViews() {
        XCTAssertEqual(sut.containerView.backgroundColor, viewModel.backgroundColor)
        XCTAssertEqual(sut.containerView.tintColor, viewModel.backgroundColor)
        XCTAssertEqual(sut.iconImageView.image, viewModel.image)

        XCTAssertEqual(sut.headlineLabel.attributedText, viewModel.title.styledAs(.header_3).aligned(to: .center))

        XCTAssertEqual(sut.subHeadlineLabel.attributedText, viewModel.subtitle.styledAs(.body).colored(.onBackground70).aligned(to: .center))
    }

    // MARK: - Mock Data

    private func createNoCertificateCell() -> NoCertificateCollectionViewCell? {
        let nib = Bundle.uiBundle.loadNibNamed("\(NoCertificateCollectionViewCell.self)", owner: nil, options: nil)
        return nib?.first as? NoCertificateCollectionViewCell
    }
}
