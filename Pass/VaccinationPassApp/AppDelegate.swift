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
    var router: MainRouter!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? UIFont.loadCustomFonts()
        window = UIWindow(frame: UIScreen.main.bounds)
        router = MainRouter()
        router.windowDelegate = self
        self.window = UIWindow(frame: UIScreen.main.bounds)
<<<<<<< HEAD
        self.window?.rootViewController = router.rootViewController()
=======
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
>>>>>>> 9ac2db5b55818a668ef7dc0cf0fdf972f5c7efac
        self.window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: WindowDelegate {
    func update(rootViewController: UIViewController) {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: { completed in
            window.rootViewController = rootViewController
        })
    }
}
