//
//  APIServiceProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit

public protocol APIServiceProtocol {
    func reissue(_ vaccinationQRCode: String) -> Promise<String>
}
