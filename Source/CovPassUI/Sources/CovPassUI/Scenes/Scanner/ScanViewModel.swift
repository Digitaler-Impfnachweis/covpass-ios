//
//  ScanViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import PromiseKit
import Scanner
import UIKit

private enum Constants {
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_button_scanner_label_close".localized)
        static let torchOn = VoiceOverOptions.Settings(label: "accessibility_button_label_torch_off".localized)
        static let torchOff = VoiceOverOptions.Settings(label: "accessibility_button_label_torch_on".localized)
        static let scanner: String = "accessibility_scan_camera_announce".localized
    }
}

class ScanViewModel: CancellableViewModelProtocol {
    // MARK: - Properties

    private let cameraAccessProvider: CameraAccessProviderProtocol
    let resolver: Resolver<ScanResult>

    var onCameraAccess: (() -> Void)?

    var hasDeviceTorch = true
    private let device: AVCaptureDevice?
    private(set) var isFlashlightOn = false

    var currentTorchVoiceOverOptions: VoiceOverOptions.Settings {
        isFlashlightOn ? Constants.Accessibility.torchOn : Constants.Accessibility.torchOff
    }

    var closeVoiceOverOptions: VoiceOverOptions.Settings {
        Constants.Accessibility.close
    }

    var accessibilityScannerText: String {
        Constants.Accessibility.scanner
    }

    // MARK: - Lifecycle

    init(
        cameraAccessProvider: CameraAccessProviderProtocol,
        resolvable: Resolver<ScanResult>
    ) {
        self.cameraAccessProvider = cameraAccessProvider
        resolver = resolvable

        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            hasDeviceTorch = false
            self.device = nil
            return
        }
        self.device = device
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
            debugPrint($0)
            self.cancel()
        }
    }

    func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    func cancel() {
        resolver.cancel()
    }

    func toggleFlashlight() {
        guard let device = self.device, hasDeviceTorch else { return }
        do {
            try device.lockForConfiguration()
            isFlashlightOn.toggle()
            device.torchMode = isFlashlightOn ? .on : .off
            device.unlockForConfiguration()
        } catch {}
    }
}
