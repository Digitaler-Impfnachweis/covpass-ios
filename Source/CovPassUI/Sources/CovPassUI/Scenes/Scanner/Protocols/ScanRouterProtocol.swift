//
//  ScanRouterProtocol.swift
//  
//
//  Created by Fatih Karakurt on 08.06.22.
//

import PromiseKit
import CovPassCommon

public enum DocumentSheetResult {
    case photo
    case document
}

public protocol ScanRouterProtocol {
    func showDocumentPickerSheet() -> Promise<DocumentSheetResult>
    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void>
}
