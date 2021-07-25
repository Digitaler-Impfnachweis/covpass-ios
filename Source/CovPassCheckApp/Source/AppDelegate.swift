//
//  AppDelegate.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var sceneCoordinator: DefaultSceneCoordinator?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        try? clearKeychainOnFreshInstall()
        try? UIFont.loadCustomFonts()

        guard NSClassFromString("XCTest") == nil else { return true }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let mainScene = MainSceneFactory(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.asRoot(mainScene)
        window.rootViewController = sceneCoordinator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.sceneCoordinator = sceneCoordinator

        appUpdateDialogIfNeeded()

        return true
    }

    private func clearKeychainOnFreshInstall() throws {
        if !UserDefaults.StartupInfo.bool(.appInstalled) {
            UserDefaults.StartupInfo.set(true, forKey: .appInstalled)
            try KeychainPersistence().delete(KeychainPersistence.trustListKey)
            try KeychainPersistence().delete(KeychainPersistence.certificateListKey)
            try KeychainPersistence().delete(KeychainPersistence.dccRulesKey)
        }
    }

    private func appUpdateDialogIfNeeded() {
        CheckAppUpdate(
            service: CheckAppUpdateService(bundleIdentifier: "de.rki.corona-impf-check"),
            userDefaults: UserDefaultsPersistence(),
            appStoreID: "id1566140314"
        ).showUpdateDialogIfNeeded(
            title: "dialog_start_screen_title".localized,
            message: "dialog_start_screen_message".localized,
            ok: "dialog_start_screen_button_update".localized,
            cancel: "dialog_start_screen_button_later".localized
        )
    }

    func applicationWillResignActive(_: UIApplication) {
        BackgroundUtils.addHideView(to: window, image: UIImage(named: "CovPassCheck"))
    }

    func applicationDidBecomeActive(_: UIApplication) {
        BackgroundUtils.removeHideView(from: window)
    }
}
