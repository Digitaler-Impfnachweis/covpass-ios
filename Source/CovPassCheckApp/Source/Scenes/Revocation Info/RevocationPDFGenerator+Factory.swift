//
//  RevocationPDFGenerator+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

extension RevocationPDFGenerator {
    convenience init?() {
        guard let url = Bundle.main.url(forResource: "RevocationInfoTemplate", withExtension: "svg"),
              let data = try? Data(contentsOf: url),
              let svgTemplate = String(data: data, encoding: .utf8) else {
                  return nil
              }
        let converter = SVGToPDFConverter()
        self.init(converter: converter, svgTemplate: svgTemplate)
    }
}
