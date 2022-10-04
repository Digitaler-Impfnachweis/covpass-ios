//
//  MaskRequiredResultRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

protocol MaskRequiredResultRouterProtocol {
    func revoke(token: ExtendedCBORWebToken, revocationKeyFilename: String)
}
