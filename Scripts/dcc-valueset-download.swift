#!/usr/bin/swift

import Foundation

let baseURL = "https://distribution.dcc-rules.de"

class ValueSetSimple: Codable {
    var id: String
    var hash: String
}

// Download list of value sets
let dataSummary = try! Data(contentsOf: URL(string: baseURL + "/valuesets")!)
let valueSetsSummary = try! JSONDecoder().decode([ValueSetSimple].self, from: dataSummary)

// Download all rules and group by country
for valueSetSummary in valueSetsSummary {
    let data = try! Data(contentsOf: URL(string: baseURL + "/valuesets/\(valueSetSummary.hash)")!)
    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

    // Save json to file
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
    try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Source/CovPassCommon/Sources/CovPassCommon/Resources/DCC-ValueSets/\(valueSetSummary.id).json"))
}