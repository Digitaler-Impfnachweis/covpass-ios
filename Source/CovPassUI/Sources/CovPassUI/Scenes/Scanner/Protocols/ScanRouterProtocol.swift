//
//  ScanRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

public enum DocumentSheetResult {
    case cancel
    case photo
    case document
}

public protocol ScanRouterProtocol {
    func showDocumentPickerSheet() -> Promise<DocumentSheetResult>
    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void>
}
