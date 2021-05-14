//
//  ScanViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Scanner
import UIKit

class ScanViewModel: CancellableViewModelProtocol {
    // MARK: - Properties

    private let cameraAccessProvider: CameraAccessProviderProtocol
    let resolver: Resolver<ScanResult>

    var onCameraAccess: (() -> Void)?

    // MARK: - Lifecycle

    init(
        cameraAccessProvider: CameraAccessProviderProtocol,
        resolvable: Resolver<ScanResult>
    ) {
        self.cameraAccessProvider = cameraAccessProvider
        resolver = resolvable
    }

    func requestCameraAccess() {
        firstly {
            cameraAccessProvider.requestAccess(for: .video)
        }
        .done {
            self.onCameraAccess?()
        }
        .cancelled {
            self.cancel()
        }
        .catch {
            print($0)
            self.cancel()
        }
    }

    func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    func cancel() {
        resolver.cancel()
    }
}
