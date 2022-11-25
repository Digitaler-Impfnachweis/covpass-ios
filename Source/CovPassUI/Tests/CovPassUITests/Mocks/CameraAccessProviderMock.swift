//
//  CameraAccessProviderMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
@testable import CovPassUI
import Foundation
import PromiseKit

struct CameraAccessProviderMock: CameraAccessProviderProtocol {
    func requestAccess(for _: AVMediaType) -> Promise<Void> {
        Promise.value
    }
}
