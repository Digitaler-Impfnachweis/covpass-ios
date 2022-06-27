//
//  ScanRouterMock.swift
//  
//
//  Created by Fatih Karakurt on 08.06.22.
//

import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ScanRouterMock: ScanRouterProtocol {
    let showDocumentPickerExpectation = XCTestExpectation(description: "showDocumentPickerExpectation")
    let showCertificatePickerExpectation = XCTestExpectation(description: "showCertificatePickerExpectation")
    var choosenDocumentType = DocumentSheetResult.photo
    var receivedTokens: [ExtendedCBORWebToken] = []
    
    func showDocumentPickerSheet() -> Promise<DocumentSheetResult> {
        showDocumentPickerExpectation.fulfill()
        return .value(choosenDocumentType)
    }

    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        receivedTokens = tokens
        showCertificatePickerExpectation.fulfill()
        return .value
    }
}
