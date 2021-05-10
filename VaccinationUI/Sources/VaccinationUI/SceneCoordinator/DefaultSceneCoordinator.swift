//
//  DefaultSceneCoordinator.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit

public class DefaultSceneCoordinator: SceneCoordinator {
    // MARK: - Properties

    public private(set) var window: UIWindow?
    public private(set) var rootViewController: UIViewController?
    private var modalSceneStack = [ModalSceneReference]()

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
        animated: Bool = true
    ) {
        guard let viewController = pushable else {
            fatalError(ScenePresentationError.notPresentable.localizedDescription)
        }
        let navigationViewController = rootViewController?.mostTopViewController as? UINavigationController
        navigationViewController?.pushViewController(
            viewController,
            animated: animated
        )
    }

    func popViewController(animated: Bool) {
        let navigationViewController = rootViewController?.mostTopViewController as? UINavigationController
        navigationViewController?.popViewController(animated: animated)
    }

    func present(
        viewController: UIViewController,
        animated: Bool = true
    ) {
        rootViewController?.mostTopViewController?.present(
            viewController,
            animated: animated,
            completion: nil
        )

        if viewController.modalInteractiveDismissible() != nil {
            let reference = ModalSceneReference(viewController: viewController)
            modalSceneStack.append(reference)
        }
    }

    func present<T>(
        viewController: UIViewController,
        promise: Promise<T>,
        animated: Bool = true
    ) -> Promise<T> {
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

    func dismissViewController(_ animated: Bool) {
        guard let viewController = rootViewController?.mostTopViewController else {
            return
        }

        dismiss(
            viewController,
            animated,
            completion: nil
        )
    }

    func dismiss(
        _ viewController: UIViewController,
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        _ = modalSceneStack.popLast()

        viewController.dismiss(
            animated: animated,
            completion: completion
        )
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
