//
//  CheckSituationRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

public protocol CheckSituationRouterProtocol: DialogRouterProtocol {
    func showOfflineRevocationDisableConfirmation() -> Guarantee<Bool>
}
