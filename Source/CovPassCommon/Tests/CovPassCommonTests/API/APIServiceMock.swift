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

class APIServiceMock: APIServiceProtocol {
    var trustListResult: Promise<String>?
    func fetchTrustList() -> Promise<String> {
        trustListResult ?? Promise.value("")
    }
}
