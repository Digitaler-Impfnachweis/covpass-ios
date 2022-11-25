//
//  Country.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum Countries {
    static let bundleURL = Bundle.commonBundle.url(forResource: "countries", withExtension: "json")

    static let downloadURL = try? FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    ).appendingPathComponent("countries.json")

    public static var hasDownloadedJson: Bool {
        FileManager.default.fileExists(atPath: Countries.downloadURL?.relativePath ?? "")
    }

    static func loadDefaultCountries() -> [Country] {
        guard let url = hasDownloadedJson ? downloadURL : bundleURL,
              let data = try? Data(contentsOf: url),
              let decoded: [Country] = try? JSONDecoder().decode([String].self, from: data).map({ .init($0) })
        else {
            return []
        }
        return decoded
    }
}

public struct Country: Decodable {
    public let code: String
    public init(_ code: String) {
        self.code = code
    }
}
