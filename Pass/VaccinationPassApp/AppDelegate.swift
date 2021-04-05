//
//  AppDelegate.swift
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationPass

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? UIFont.loadCustomFonts()
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = PassUIConstants.Storyboard.pass.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        return true
    }
}
