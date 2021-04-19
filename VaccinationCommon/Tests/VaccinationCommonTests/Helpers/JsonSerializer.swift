//
//  JsonSerializer.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationCommon

class JsonSerializer {
    static func json(fromUTF8String string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8) else { return nil }

        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Serialization failed with \(error)")
            return nil
        }
    }

    static func json(forResource string: String) -> [String: Any]? {
        let bundle = Bundle.module
        guard
            let url = bundle.url(forResource: string, withExtension: "json"),
            let jsonString = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        return json(fromUTF8String: jsonString)
    }
}
