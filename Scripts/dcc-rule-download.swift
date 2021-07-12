#!/usr/bin/swift

import Foundation

let baseURL = "https://distribution-dfe4f5c711db.dcc-rules.de"

class RuleSimple: Codable {
    var identifier: String
    var version: String
    var country: String
    var hash: String
}

// Download list of rules
let dataSummary = try! Data(contentsOf: URL(string: baseURL + "/rules")!)
let rulesSummary = try! JSONDecoder().decode([RuleSimple].self, from: dataSummary)

// Download all rules and group by country
var result = [[String: Any]]()
for ruleSummary in rulesSummary {
    let data = try! Data(contentsOf: URL(string: baseURL + "/rules/\(ruleSummary.country)/\(ruleSummary.hash)")!)
    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    result.append(json)
}

// Save json to file
let jsonData = try! JSONSerialization.data(withJSONObject: result, options: [])
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("../Certificates/DEMO/DCC/dcc-rules.json"))
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("../Certificates/PROD/DCC/dcc-rules.json"))
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("../Certificates/PROD_RKI/DCC/dcc-rules.json"))