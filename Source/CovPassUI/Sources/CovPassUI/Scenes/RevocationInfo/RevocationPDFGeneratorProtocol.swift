//
//  RevocationPDFGeneratorProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PDFKit
import PromiseKit

public protocol RevocationPDFGeneratorProtocol: AnyObject {
    func generate(with: RevocationInfo) -> Promise<PDFDocument>
}

struct RevocationPDFGeneratorError: Error {}
