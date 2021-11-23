// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//
import Foundation

public class Fastfile: LaneFile {
    /// Build and test given project
    ///
    /// - Parameters:
    ///   - root_path: The project folder
    ///   - scheme: The projects scheme
    ///   - path: All paths that should be linted. Separate them with a ,
    ///   - device: Simulator name; Default iPhone 11 (optional)
    ///   - coverage: The min coverage for the project
    func buildAndTestLane(withOptions options: [String: String]?) {
        desc("Build and test given project")
        if checkCiSkipLane(withOptions: options) { return }

        guard let rootPath = options?["root_path"] else {
            abort(message: "Missing parameter 'root_path'")
            return
        }

        echo(message: "Project changed; Start build and test")
        clearDerivedData(derivedDataPath: derivedData())
//            lintLane(withOptions: options)
        unitTestLane(withOptions: options)
        if isCi() {
            codeCoverageLane(withOptions: options)
        }
    }

    /// Run unit tests of given target
    ///
    /// - Parameters:
    ///   - root_path: The project folder
    ///   - scheme: The projects scheme
    ///   - device: Simulator name; Default iPhone 11 (optional)
	func unitTestLane(withOptions options: [String: String]?) {
        desc("Run unit tests of given target")
        if checkCiSkipLane(withOptions: options) { return }

        guard let scheme = options?["scheme"] else {
            abort(message: "Missing parameter 'scheme'")
            return
        }
        var device = "iPhone 11"
        if let optionDevice = options?["device"] {
            device = optionDevice
        }

        // Copy config files
        _ = execute("sh", "./Scripts/copy-config-files.sh debug")

        runTests(
            project: "./CovPass.xcodeproj",
            scheme: .userDefined(scheme),
            device: .userDefined(device),
            clean: true,
            codeCoverage: .userDefined(true),
            outputDirectory: outputDirectory(),
            derivedDataPath: .userDefined(derivedData()),
            configuration: "Debug"
        )
	}

    /// Lint project with swiftlint
    ///
    /// - Parameters:
    ///   - root_path: The project folder
    ///   - path: All paths that should be linted. Separate them with a ,
    func lintLane(withOptions options: [String: String]?) {
        desc("Lint project with swiftlint")
        if checkCiSkipLane(withOptions: options) { return }

        guard let rootPath = options?["root_path"] else {
            abort(message: "Missing parameter 'root_path'")
            return
        }
        guard let optionPath = options?["path"] else {
            abort(message: "Missing parameter 'path'")
            return
        }
        let paths = optionPath.split(separator: ",")
        let config = "\(pwd())/.swiftlint.yml"

        for path in paths {
            swiftlint(
                mode: "lint",
                path: "\(rootPath)/\(path)",
                configFile: .userDefined(config),
                quiet: false
            )
        }
    }

    /// Calculate code coverage and report to GitHub
    ///
    /// - Parameters:
    ///   - root_path: The project folder
    ///   - scheme: The projects scheme
    ///   - coverage: The min coverage for the project
    func codeCoverageLane(withOptions options: [String: String]?) {
        desc("Lint project with swiftlint")
        if checkCiSkipLane(withOptions: options) { return }

        guard let rootPath = options?["root_path"] else {
            abort(message: "Missing parameter 'root_path'")
            return
        }
        guard let scheme = options?["scheme"] else {
            abort(message: "Missing parameter 'scheme'")
            return
        }
        guard let coverageString = options?["coverage"], let minCoverage = Double(coverageString) else {
            abort(message: "Missing parameter 'coverage'")
            return
        }

        slather(
         buildDirectory: "\(derivedData())",
         proj: "CovPass.xcodeproj",
         scheme: .userDefined(scheme),
         jenkins: .userDefined(true),
         coberturaXml: .userDefined(true),
         outputDirectory: .userDefined(outputDirectory()),
         ignore: .userDefined(["*Tests/*"]),
         useBundleExec: .userDefined(true)
        )

        slather(
         buildDirectory: "\(derivedData())",
         proj: "CovPass.xcodeproj",
         scheme: .userDefined(scheme),
         jenkins: .userDefined(true),
         html: .userDefined(true),
         outputDirectory: .userDefined("\(outputDirectory())/html"),
         ignore: .userDefined(["*Tests/*"]),
         useBundleExec: .userDefined(true)
        )

        verifyCodeCoverage(name: rootPath, file: "\(outputDirectory())/cobertura.xml", minCoverage: minCoverage)
    }
}

extension Fastfile {
    func execute(_ program: String, _ command: String) -> String {
        echo(message: "\(program): \(command)")
        let cmd = RubyCommand(commandID: "", methodName: program, className: nil, args: [RubyCommand.Argument(name: "command", value: command)])
        return runner.executeCommand(cmd).replacingOccurrences(of: "\n", with: "")
    }

    func pwd() -> String {
        return execute("sh", "pwd")
    }

    func derivedData() -> String {
        return "\(pwd())/DerivedData"
    }

    func outputDirectory() -> String {
        return "\(pwd())/Reports"
    }

    func abort(message: String) {
        echo(message: .userDefined(message))
        _ = execute("exit", "exit")
    }

    func verifyCodeCoverage(name: String, file: String, minCoverage: Double) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: file))
            let report = String(data: data, encoding: .utf8) ?? ""
            guard let coverage = try extractCodeCoverage(in: report) else {
                abort(message: "Code coverage not found")
                return
            }

            // true = success
            let status = coverage >= minCoverage

            // Report coverage to github
            let jobUrl = environmentVariable(get: "JOB_URL")
            let githubOauthToken = environmentVariable(get: "GITHUB_OAUTH_TOKEN")
            if jobUrl.isEmpty || githubOauthToken.isEmpty {
                abort(message: "Skip code coverage report; reason: no JOB_URL or GITHUB_OAUTH_TOKEN")
                return
            }

            githubApi(
                serverUrl: "https://github.ibmgcloud.net/api/v3",
                apiToken: .userDefined(githubOauthToken),
                httpMethod: "POST",
                body: [
                    "target_url": "\(jobUrl)Coverage_20Report",
                    "context": "Code Coverage \(name)",
                    "description": "Coverage: \(coverage.rounded(toPlaces: 2)) / \(minCoverage) - \(status ? "success" : "failure")",
                    "state": status ? "success" : "failure"
                ],
                path: "/repos/eGA/ios-covpass/statuses/\(lastGitCommitHash())"
            )

            if !status {
                abort(message: "Code coverage \(coverage.rounded(toPlaces: 2)) below \(minCoverage)")
                return
            }

        } catch {
            abort(message: error.localizedDescription)
        }
    }

    func extractCodeCoverage(in text: String) throws -> Double? {
        let regex = try NSRegularExpression(pattern: "coverage line-rate=\\\"([0-9.]*)\\\"")
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let result = results.first,
              let range = Range(result.range(at: 1), in: text),
              let coverage = Double(text[range]) else {
            return nil
        }
        return coverage * 100.0
    }

    func checkCiSkipLane(withOptions options: [String: String]?) -> Bool {
        let noSkip = (options?["no_skip"] ?? "") == "true"
        if noSkip {
            return false
        }
        let commitMsg = execute("sh", "git log -1 --pretty=%B")
        guard let ciSkip = try? extract(in: commitMsg, with: "^(\\[ci-skip\\])"), ciSkip != nil, !ciSkip!.isEmpty else {
            return false
        }
        echo(message: "Skip PR build; Reason ci-skip")
        return true
    }

    func lastGitCommitHash() -> String {
        let lastCommit = lastGitCommit()
        return lastCommit["commit_hash"] ?? ""
    }

    func extract(in text: String, with pattern: String) throws -> String? {
        let regex = try NSRegularExpression(pattern: pattern)
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let result = results.first, let range = Range(result.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
