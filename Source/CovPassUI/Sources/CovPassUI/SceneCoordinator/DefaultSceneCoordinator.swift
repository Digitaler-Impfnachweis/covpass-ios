//
//  DefaultSceneCoordinator.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public class DefaultSceneCoordinator: NSObject, SceneCoordinator {
    // MARK: - Properties

    public private(set) var window: UIWindow?
    public private(set) var rootViewController: UIViewController?
    private(set) var modalSceneStack = [ModalSceneReference]()
    private(set) var navigationSceneStack = [NavigationSceneReference]()

    // MARK: - Lifecycle

    public init(window: UIWindow?, rootViewController: UIViewController? = nil) {
        self.window = window
        self.rootViewController = rootViewController
        super.init()
    }

    // MARK: - Methods

    func asRootViewController(_ viewController: UIViewController?) {
        window?.rootViewController = viewController
        rootViewController = viewController
    }

    func push(
        viewController: UIViewController,
        animated: Bool = true
    ) {
        let navigationViewController = rootViewController?.mostTopViewController as? UINavigationController
        navigationViewController?.pushViewController(
            viewController,
            animated: animated
        )
    }

    func push<T>(
        viewController: UIViewController,
        promise: Promise<T>,
        animated: Bool = true
    ) -> Promise<T> {

        push(viewController: viewController, animated: animated)

        let (internalPromise, internalResolver) = Promise<T>.pending()
        let navigationController = rootViewController?.mostTopViewController as? UINavigationController
        navigationController?.delegate = self
        let sceneReference = NavigationSceneReference(viewController: viewController)
        navigationSceneStack.append(sceneReference)

        sceneReference.didPop = { vc in

            self.removeNavigationStackReferrenceIfNeeded(for: vc)

            // if origin promise is still pending means the user canncelled the view by back button or swipe gesture.
            guard promise.isPending == false else {
                internalResolver.cancel()
                return
            }
            // finally resolve internal promise
            promise
                .done(internalResolver.fulfill)
                .cancelled(internalResolver.cancel)
                .catch(internalResolver.reject)
        }

        promise
            .done { _ in navigationController?.popViewController(animated: true) }
            .cancelled { navigationController?.popViewController(animated: true) }
            .catch { _ in navigationController?.popViewController(animated: true) }

        return internalPromise
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
        if let viewController = rootViewController?.mostTopViewController {
            dismiss(
                viewController,
                animated,
                completion: nil
            )
        }
    }

    // MARK: - Helper

    private func dismiss(
        _ viewController: UIViewController,
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        removeModalStackReferrenceIfNeeded(for: viewController)

        viewController.dismiss(
            animated: animated,
            completion: completion
        )
    }

    /// Removes reference from navigation stack for given viewController
    private func removeNavigationStackReferrenceIfNeeded(for viewController: UIViewController) {
        if let index = navigationSceneStack.firstIndex(where: { $0.viewController == viewController }) {
            navigationSceneStack.remove(at: index)
        }
    }

    /// Removes reference from modal stack for given viewController
    private func removeModalStackReferrenceIfNeeded(for viewController: UIViewController) {
        if let index = modalSceneStack.firstIndex(where: { $0.viewController == viewController }) {
            modalSceneStack.remove(at: index)
        }
    }
}

extension DefaultSceneCoordinator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationSceneStack.forEach {
            $0.navigationController(navigationController, didShow: viewController, animated: animated)
        }
    }
}
