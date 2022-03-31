//
//  RevocationPDFGenerator+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

extension RevocationPDFGenerator {
    convenience init?(keyFilename: String) {
        let bundle = Bundle.module
        guard let svgTemplate = try? bundle.loadString(resource: "RevocationInfoTemplate.svg", encoding: .utf8),
              let keyString = try? bundle.loadString(resource: keyFilename, encoding: .ascii),
              let secKey = try? keyString.secKey()
        else {
            return nil
        }
        let converter = SVGToPDFConverter()
        let jsonEncoder = JSONEncoder()

        self.init(
            converter: converter,
            jsonEncoder: jsonEncoder,
            svgTemplate: svgTemplate,
            secKey: secKey
        )
    }
}
