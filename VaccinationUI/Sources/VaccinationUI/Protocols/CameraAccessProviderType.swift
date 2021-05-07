//
//  CameraAccessProviderProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import AVFoundation
import Foundation
import PromiseKit

public protocol CameraAccessProviderProtocol {
    func requestAccess(for mediaType: AVMediaType) -> Promise<Void>
}
