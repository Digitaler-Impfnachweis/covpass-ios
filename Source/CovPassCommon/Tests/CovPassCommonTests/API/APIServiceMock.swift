//
//  APIServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

@testable import CovPassCommon

struct APIServiceMock: APIServiceProtocol {
    func fetchTrustList() -> Promise<String> {
        Promise.value("")
    }
}
