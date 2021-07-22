//
//  CheckAppUpdate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import UIKit

public enum CheckAppUpdateError: Error {
    case noBundleVersion
    case noBundleIdentifier
    case invalidURL
    case invalidResponse
}

public protocol CheckAppUpdateServiceProtocol {
    func getAppStoreVersion() -> Promise<String>
}

struct AppStoreResultItem: Codable {
    var version: String
}

struct AppStoreResult: Codable {
    var resultCount: Int
    var results: [AppStoreResultItem]
}

public struct CheckAppUpdateService: CheckAppUpdateServiceProtocol {

    private let bundleIdentifier: String

    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
    }

    public func getAppStoreVersion() -> Promise<String> {
        firstly {
            Promise { seal in
                guard let url = URL(string: "http://itunes.apple.com/de/lookup?bundleId=\(bundleIdentifier)") else {
                    throw CheckAppUpdateError.invalidURL
                }
                seal.fulfill(url)
            }
        }
        .then(on: .global()) { url in
            requestVersion(url)
        }
    }

    private func requestVersion(_ url: URL) -> Promise<String> {
        Promise { seal in
            print("Request AppStore version \(url.absoluteString)")
            let data = try Data(contentsOf: url)
            let res = try JSONDecoder().decode(AppStoreResult.self, from: data)
            guard let item = res.results.first, !item.version.isEmpty else {
                throw CheckAppUpdateError.invalidResponse
            }
            seal.fulfill(item.version)
        }
    }
}

public typealias VersionUpdate = (shouldUpdate: Bool, version: String, currentVersion: String)

public struct CheckAppUpdate {

    private let service: CheckAppUpdateServiceProtocol
    private let userDefaults: Persistence
    var bundleVersion: String?
    var appStoreID: String

    public init(service: CheckAppUpdateServiceProtocol, userDefaults: Persistence, appStoreID: String) {
        self.service = service
        self.userDefaults = userDefaults
        self.bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.appStoreID = appStoreID
    }

    public func showUpdateDialogIfNeeded(title: String, message: String, ok: String, cancel: String) {
        firstly {
            updateAvailable()
        }
        .done { versionUpdate in
            if !versionUpdate.shouldUpdate { return }
            print("Show update dialog for version \(versionUpdate.version)")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: cancel, style: .default) { _ in
                // User doesn't want to update the app, don't show the dialog until next version
                try? userDefaults.store(UserDefaults.keyCheckVersionUpdate, value: versionUpdate.currentVersion)
            })
            alertController.addAction(UIAlertAction(title: ok, style: .default) { _ in
                // User doesn't want to update the app, don't show the dialog until next version
                try? userDefaults.store(UserDefaults.keyCheckVersionUpdate, value: versionUpdate.currentVersion)
                if let url = URL(string: "itms-apps://apple.com/app/\(appStoreID)") {
                    UIApplication.shared.open(url)
                }
            })

            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true)
        }
        .catch { error in
            if type(of: error) != PromiseCancelledError.self {
                print(error.localizedDescription)
            }
        }
    }

    // True if new update is available
    public func updateAvailable() -> Promise<VersionUpdate> {
        firstly {
            checkBundleVersion()
        }
        .then(on: .global()) { bundleVersion in
            checkAppStoreIfNeeded(bundleVersion)
        }
        .map(on: .global()) { bundleVersion in
            let appStoreVersion = try service.getAppStoreVersion().wait()
            return (shouldUpdate: bundleVersion != appStoreVersion, version: appStoreVersion, currentVersion: bundleVersion)
        }
    }

    private func checkBundleVersion() -> Promise<String> {
        Promise { seal in
            guard let version = bundleVersion else {
                throw CheckAppUpdateError.noBundleVersion
            }
            seal.fulfill(version)
        }
    }

    private func checkAppStoreIfNeeded(_ bundleVersion: String) -> Promise<String> {
        Promise { seal in
            guard let lastVersion = try? userDefaults.fetch(UserDefaults.keyCheckVersionUpdate) as? String else {
                seal.fulfill(bundleVersion)
                return
            }
            if bundleVersion == lastVersion {
                // User declined update before, don't show the message again
                throw PromiseCancelledError()
            }
            seal.fulfill(bundleVersion)
        }
    }
}
