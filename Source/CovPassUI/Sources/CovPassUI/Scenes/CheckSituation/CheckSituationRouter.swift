//
//  CheckSituationRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

private enum Constants {
    static let offlineRevocationDisableConfirmationTitle = "app_information_offline_revocation_hint_title".localized(bundle: .main)
    static let offlineRevocationDisableConfirmationMessage = "app_information_offline_revocation_hint_copy".localized(bundle: .main)
    static let offlineRevocationDisableConfirmationOk = "ok".localized(bundle: .main)
    static let offlineRevocationDisableConfirmationCancel = "cancel".localized(bundle: .main)
}

public struct CheckSituationRouter: CheckSituationRouterProtocol, DialogRouterProtocol {
    public var sceneCoordinator: SceneCoordinator

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func showOfflineRevocationDisableConfirmation() -> Guarantee<Bool> {
        Guarantee { seal in
            let actions: [DialogAction] = [
                .init(
                    title: Constants.offlineRevocationDisableConfirmationOk,
                    style: .destructive,
                    isEnabled: true,
                    completion: { _ in seal(true) }
                ),
                .init(
                    title: Constants.offlineRevocationDisableConfirmationCancel,
                    style: .cancel,
                    isEnabled: true,
                    completion: { _ in seal(false) }
                )
            ]

            showDialog(
                title: Constants.offlineRevocationDisableConfirmationTitle,
                message: Constants.offlineRevocationDisableConfirmationMessage,
                actions: actions,
                style: .alert
            )
        }
    }
}
