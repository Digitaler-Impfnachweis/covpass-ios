//
//  RevocationInfoViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class RevocationInfoViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: RevocationInfoViewController!
    override func setUpWithError() throws {
        try super.tearDownWithError()
        let (_, resolver) = Promise<Void>.pending()
        let pdfGenerator = RevocationPDFGenerator(
            converter: SVGToPDFConverter(),
            jsonEncoder: JSONEncoder(),
            svgTemplate: ""
        )
        let viewModel = RevocationInfoViewModel(
            router: RevocationInfoRouterMock(),
            resolver: resolver,
            pdfGenerator: pdfGenerator,
            fileManager: FileManager.default,
            token: .init(
                vaccinationCertificate: .mockVaccinationCertificate,
                vaccinationQRCodeData: ""
            ),
            coseSign1Message: .mock(),
            timestamp: Date()
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() {
        // TODO: Fix execution halts.
        // verifyView(vc: sut)
    }
}
