//
//  ScanViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import Scanner
import UIKit

public typealias ScanResult = Swift.Result<String, ScanError>

public class ScanViewModel: CancellableViewModelProtocol {
    // MARK: - Properties

    private let cameraAccessProvider: CameraAccessProviderProtocol
    let resolver: Resolver<ScanResult>

    var onCameraAccess: (() -> Void)?

    // MARK - Lifecycle

    public init(
        cameraAccessProvider: CameraAccessProviderProtocol,
        resolvable: Resolver<ScanResult>) {

        self.cameraAccessProvider = cameraAccessProvider
        self.resolver = resolvable
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

    public func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    public func cancel() {
        resolver.cancel()
    }
}
