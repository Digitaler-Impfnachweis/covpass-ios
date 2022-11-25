//
//  String+SVG.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

extension String {
    func svgTspans(nrOfCharacters: Int, yStart: Int, lineSpacing: Int) -> Self {
        var result = ""
        var y = yStart
        var stringToProcess = self
        while !stringToProcess.isEmpty {
            let prefix = String(stringToProcess.prefix(nrOfCharacters))
            result.append(prefix.tspan(y: y))
            stringToProcess = String(stringToProcess.dropFirst(nrOfCharacters))
            y += lineSpacing
        }
        return result
    }

    private func tspan(y: Int) -> Self {
        String(format: "<tspan x=\"0\" y=\"\(y)\">\(self)</tspan>", y, self)
    }
}
