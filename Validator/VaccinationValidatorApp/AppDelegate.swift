//
//  AppDelegate.swift
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationValidator

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sceneCoordinator: DefaultSceneCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        try? UIFont.loadCustomFonts()

        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let mainScene = ValidatorAppSceneFactory(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.asRoot(mainScene)
        window.rootViewController = sceneCoordinator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.sceneCoordinator = sceneCoordinator

        return true
    }

//    var window: UIWindow?
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        try? UIFont.loadCustomFonts()
//        window = UIWindow(frame: UIScreen.main.bounds)
//        var router = MainRouter()
//        router.windowDelegate = self
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        self.window?.rootViewController = router.rootViewController()
//        self.window?.makeKeyAndVisible()
//        return true
//    }
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
