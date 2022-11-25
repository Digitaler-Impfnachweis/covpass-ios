//
//  ScanRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ScanRouterMock: ScanRouterProtocol {
    let showDocumentPickerExpectation = XCTestExpectation()
    var choosenDocumentType = DocumentSheetResult.photo

    func showDocumentPickerSheet() -> Promise<DocumentSheetResult> {
        showDocumentPickerExpectation.fulfill()
        return .value(choosenDocumentType)
    }

    func showCertificatePicker(tokens _: [ExtendedCBORWebToken]) -> Promise<Void> {
        .value
    }
}
