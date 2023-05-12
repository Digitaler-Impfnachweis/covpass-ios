#!/usr/bin/swift

import Foundation

let baseURL = "https://distribution.dcc-rules.de"

class RuleSimple: Codable {
    var identifier: String
    var version: String
    var hash: String
}

// Download list of rules
let dataSummary = try! Data(contentsOf: URL(string: baseURL + "/bnrules")!)
let rulesSummary = try! JSONDecoder().decode([RuleSimple].self, from: dataSummary)

// Download all rules
var result = [[String: Any]]()
for ruleSummary in rulesSummary {
    let data = try! Data(contentsOf: URL(string: baseURL + "/bnrules/\(ruleSummary.hash)")!)
    var json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    json["hash"] = ruleSummary.hash
    result.append(json)
}

// Save json to file
let jsonData = try! JSONSerialization.data(withJSONObject: result, options: [])
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Certificates/DEMO/DCC/dcc-bn-rules.json"))
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Certificates/PROD/DCC/dcc-bn-rules.json"))
try! jsonData.write(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Certificates/PROD_RKI/DCC/dcc-bn-rules.json"))
