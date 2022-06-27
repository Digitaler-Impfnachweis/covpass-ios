//
//  ScanSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI
import PromiseKit
import XCTest

class ScanSceneFactoryTests: XCTestCase {
    private var sut: ScanSceneFactory!

    override func setUpWithError() throws {
        sut = .init(
            cameraAccessProvider: CameraAccessProviderMock(),
            router: ScanRouterMock(),
            isDocumentPickerEnabled: true
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testMake() {
        // Given
        let (_, resolver) = Promise<ScanResult>.pending()

        // When
        _ = sut.make(resolvable: resolver)
    }
}
