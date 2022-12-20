//
//  SVGPDFExporter+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

extension SVGPDFExporter {
    convenience init?() {
        self.init(converter: SVGToPDFConverter())
    }
}
