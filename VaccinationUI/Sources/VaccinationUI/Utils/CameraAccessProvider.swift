//
//  PermissionProvider.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import AVFoundation
import UIKit
import PromiseKit

public class CameraAccessProvider: CameraAccessProviderProtocol {
    // MARK: - Properties

    private let router: DialogRouterProtocol

    // MARK: - Lifecycle

    public init(router: DialogRouterProtocol) {
        self.router = router
    }

    public func requestAccess(for mediaType: AVMediaType) -> Promise<Void> {
        firstly {
            requestAvCaptureAccess(for: mediaType)
        }
        .then { status -> Promise<Void> in
            guard status != .authorized else {
                return .value(())
            }
            return self.displayMissingAuthorizationDialog()
        }
    }

    private func requestAvCaptureAccess(for mediaType: AVMediaType) -> Promise<AVAuthorizationStatus> {
        .init { resolver in
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)

            guard authorizationStatus == .notDetermined else {
                resolver.fulfill(authorizationStatus)
                return
            }

            AVCaptureDevice.requestAccess(for: mediaType) { _ in
                let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
                resolver.fulfill(authorizationStatus)
            }
        }
    }

    private func displayMissingAuthorizationDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "Einstellungen".localized, style: .default) { _ in
                self.showAppSettings()
                seal.cancel()
            }
            let cancel = DialogAction(title: "Abbrechen".localized, style: .cancel) { _ in
                seal.cancel()
            }
            self.router.showDialog(
                title: "Fehlende Berechtigung".localized,
                message: "Bitte aktivieren Sie die Kamera in den Einstellungen".localized,
                actions: [cancel, delete],
                style: .alert
            )
        }
    }

    private func showAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
