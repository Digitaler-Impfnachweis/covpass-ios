//
//  CameraAccessProviderMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassUI
import PromiseKit
import AVFoundation

struct CameraAccessProviderMock: CameraAccessProviderProtocol {
    func requestAccess(for mediaType: AVMediaType) -> Promise<Void> {
        Promise.value
    }
}
