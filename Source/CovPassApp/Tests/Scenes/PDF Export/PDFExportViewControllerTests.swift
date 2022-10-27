//
//  PDFExportViewControllerTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

class PDFExportViewControllerTests: XCTestCase {

    private var viewModel: PDFExportViewModel!
    private var sut: PDFExportViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let token = try ExtendedCBORWebToken.token1Of1()
        let exporter = SVGPDFExporter()!
        viewModel = PDFExportViewModel(token: token, resolvable: resolver, exporter: exporter)
        sut = PDFExportViewController(viewModel: viewModel)
    }

    override func tearDown() {
        viewModel = nil
        sut = nil
        super.tearDown()
    }

    func testPDFFilename() {
        XCTAssertEqual(sut.filename, "Certificate-Erika-Dörte-Schmitt-Mustermann-9A3S.pdf")
    }
}
