//
//  DefaultSceneCoordinator.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit

public class DefaultSceneCoordinator: SceneCoordinator {
    // MARK: - Properties

    public private(set) var window: UIWindow?
    public private(set) var rootViewController: UIViewController?

    // MARK: - Lifecycle

    public init(window: UIWindow?, rootViewController: UIViewController? = nil) {
        self.window = window
        self.rootViewController = rootViewController
    }

    // MARK: - Methods

    func asRootViewController(_ viewController: UIViewController?) {
        window?.rootViewController = viewController
        rootViewController = viewController
    }

    func push(
        pushable: UIViewController?,
        animated: Bool = true) {

        guard let viewController = pushable else {
            fatalError(ScenePresentationError.notPresentable.localizedDescription)
        }
        let navigationViewController = rootViewController?.mostTopViewController as? UINavigationController
        navigationViewController?.pushViewController(viewController, animated: animated)
    }

    func popViewController(animated: Bool) {
        let navigationViewController = rootViewController?.mostTopViewController as? UINavigationController
        navigationViewController?.popViewController(animated: animated)
    }

    func present(
        viewController: UIViewController,
        animated: Bool = true) {

        let presenter = rootViewController?.mostTopViewController

        guard shouldCreateNavigationController(for: viewController) else {
            presenter?.present(viewController, animated: animated, completion: nil)
            return
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = viewController.modalPresentationStyle
        presenter?.present(navigationController, animated: animated, completion: nil)
    }

    func present<T>(
        viewController: UIViewController,
        promise: Promise<T>,
        animated: Bool = true) -> Promise<T> {

        present(viewController: viewController, animated: animated)

        // Map to an internal resolver to resolve only when view did dismiss.
        let (internalPromise, internalResolver) = Promise<T>.pending()

        promise.done { value in
            self.dismiss(viewController, animated) {
                internalResolver.fulfill(value)
            }
        }
        .cancelled {
            self.dismiss(viewController, animated) {
                internalResolver.cancel()
            }
        }
        .catch { error in
            self.dismiss(viewController, animated) {
                internalResolver.reject(error)
            }
        }

        return internalPromise
    }

    func dismiss(
        _ viewController: UIViewController,
        _ animated: Bool,
        completion: (() -> Void)? = nil) {

        viewController.dismiss(animated: animated, completion: completion)
    }

    // MARK: - Helper

    private func shouldCreateNavigationController(for viewController: UIViewController) -> Bool {
        let blackList = [
            UINavigationController.self,
            UIAlertController.self
        ]
        let isOnBlackList = blackList.contains { type(of: viewController) == $0 }
        return isOnBlackList == false
    }
}
