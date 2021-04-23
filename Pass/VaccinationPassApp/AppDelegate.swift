//
//  AppDelegate.swift
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Keychain
import UIKit
import VaccinationCommon
import VaccinationUI
import VaccinationPass

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? clearKeychainOnFreshInstall()
        try? UIFont.loadCustomFonts()
        window = UIWindow(frame: UIScreen.main.bounds)
        var router = MainRouter()
        router.windowDelegate = self
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = router.rootViewController()
        self.window?.makeKeyAndVisible()
        return true
    }

    private func clearKeychainOnFreshInstall() throws {
        if !UserDefaults.StartupInfo.bool(.appInstalled) {
            UserDefaults.StartupInfo.set(true, forKey: .appInstalled)
            try Keychain.deletePassword(for: KeychainConfiguration.vaccinationCertificateKey)
        }
    }
}

// MARK: - WindowDelegate

extension AppDelegate: WindowDelegate {
    func update(rootViewController: UIViewController) {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: { completed in
            window.rootViewController = rootViewController
        })
    }
}
