//
//  CameraAccessProviderProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import Foundation
import PromiseKit

public protocol CameraAccessProviderProtocol {
    func requestAccess(for mediaType: AVMediaType) -> Promise<Void>
}
