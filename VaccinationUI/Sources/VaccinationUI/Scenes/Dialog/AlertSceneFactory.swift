//
//  CertificateViewControllerFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit

public struct AlertSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    public let title: String?
    public let message: String?
    public let actions: [DialogAction]
    public let style: UIAlertController.Style

    // MARK: - Lifecycle

    public init(
        title: String? = nil,
        message: String? = nil,
        actions: [DialogAction],
        style: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.style = style
    }

    // MARK: - Methods

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { dialogAction in
            let alertAction = UIAlertAction(title: dialogAction.title, style: dialogAction.style ?? .default) { _ in
                dialogAction.completion?(dialogAction)
                resolvable.fulfill_()
            }
            alertAction.isEnabled = dialogAction.isEnabled
            alertController.addAction(alertAction)
        }
        return alertController
    }
}
