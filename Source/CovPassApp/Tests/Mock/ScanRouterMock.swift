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
    let showDocumentPickerExpectation = XCTestExpectation()
    var choosenDocumentType = DocumentSheetResult.photo
    
    func showDocumentPickerSheet() -> Promise<DocumentSheetResult> {
        showDocumentPickerExpectation.fulfill()
        return .value(choosenDocumentType)
    }

    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        .value
    }
}
