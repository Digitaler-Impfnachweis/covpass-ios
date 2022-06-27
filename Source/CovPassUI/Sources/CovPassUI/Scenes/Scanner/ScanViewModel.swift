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
import CovPassCommon

private enum Constants {
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_button_scanner_label_close".localized)
        static let torchOn = VoiceOverOptions.Settings(label: "accessibility_button_label_torch_off".localized)
        static let torchOff = VoiceOverOptions.Settings(label: "accessibility_button_label_torch_on".localized)
        static let documentPicker = VoiceOverOptions.Settings(label: "accessibility_scan_camera_select_file".localized)
        static let scanner: String = "accessibility_scan_camera_announce".localized
    }
}

protocol ScanViewModelDelegate: AnyObject {
    func selectFiles()
    func selectImages()
}

public class ScanViewModel: CancellableViewModelProtocol {
    // MARK: - Properties

    private let cameraAccessProvider: CameraAccessProviderProtocol
    let resolver: Resolver<ScanResult>
    var delegate: ScanViewModelDelegate?
    var onCameraAccess: (() -> Void)?
    var isDocumentPickerEnabled: Bool
    var hasDeviceTorch = true
    private let device: AVCaptureDevice?
    private(set) var isFlashlightOn = false
    private let router: ScanRouterProtocol
    private let certificateExtractor: CertificateExtractorProtocol?
    private let certificateRepository: VaccinationRepositoryProtocol?

    var currentTorchVoiceOverOptions: VoiceOverOptions.Settings {
        isFlashlightOn ? Constants.Accessibility.torchOn : Constants.Accessibility.torchOff
    }
    
    var closeVoiceOverOptions: VoiceOverOptions.Settings {
        Constants.Accessibility.close
    }
    
    var documentPickerVoiceOverOptions: VoiceOverOptions.Settings {
        Constants.Accessibility.documentPicker
    }
    
    var accessibilityScannerText: String {
        Constants.Accessibility.scanner
    }

    // MARK: - Lifecycle

    public init(
        cameraAccessProvider: CameraAccessProviderProtocol,
        resolvable: Resolver<ScanResult>,
        router: ScanRouterProtocol,
        isDocumentPickerEnabled: Bool,
        certificateExtractor: CertificateExtractorProtocol?,
        certificateRepository: VaccinationRepositoryProtocol?
    ) {
        self.cameraAccessProvider = cameraAccessProvider
        resolver = resolvable
        self.router = router
        self.certificateRepository = certificateRepository
        self.certificateExtractor = certificateExtractor
        self.isDocumentPickerEnabled = isDocumentPickerEnabled
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

    public func cancel() {
        resolver.cancel()
    }
    
    func documentPicker() {
        router.showDocumentPickerSheet()
            .done { sheetResult in
                switch sheetResult {
                case .document:
                    self.delegate?.selectFiles()
                case .photo:
                    self.delegate?.selectImages()
                    break
                }
            }.cauterize()
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
    
    func documentPicked(at url:[URL]) {
        guard let firstURL = url.first,
              let pdfDocument = try? QRCodePDFDocument(with: firstURL) else {
            return
        }
        extractCertificates(from: pdfDocument)
    }
    
    private func extractCertificates(from document: QRCodeDocumentProtocol) {
        guard let pdfCBORExtractor = certificateExtractor,
              let certificateRepository = certificateRepository else {
            return
        }
        firstly {
            certificateRepository.getCertificateList()
        }.then { certificateList in
            pdfCBORExtractor.extract(
                document: document,
                ignoreTokens: certificateList.certificates
            )
        }
        .then{ tokens in
            self.router.showCertificatePicker(tokens: tokens)
        }
        .cauterize()
    }
    
    func imagePicked(images: [UIImage]) {
        let document = QRCodeImagesDocument(images: images)
        extractCertificates(from: document)
    }
}
