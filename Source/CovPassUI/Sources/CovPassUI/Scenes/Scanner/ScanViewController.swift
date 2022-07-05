//
//  ScanViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import Scanner
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import PhotosUI

public final class ScanViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: - IBOutlet

    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var container: UIView!

    // MARK: - Properties

    private(set) var viewModel: ScanViewModel
    var scanViewController: ScannerViewController?

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    public init(viewModel: ScanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .backgroundPrimary
        container.backgroundColor = .neutralBlack
        configureToolbarView()
        viewModel.onCameraAccess = { [weak self] in
            self?.configureScanView()
        }
        viewModel.requestCameraAccess()
    }

    // MARK: - Private

    private func configureScanView() {
        removeScanView()
        let viewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, delegate: self)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.view.pinEdges(to: container)
        scanViewController = viewController
        UIAccessibility.post(notification: .screenChanged, argument: viewModel.accessibilityScannerText)
    }

    private func configureToolbarView() {
        if viewModel.isDocumentPickerEnabled {
            toolbarView.state = .plain
            toolbarView.setUpRightButton(rightButtonItem: .cancelButton)
            toolbarView.setUpLeftButton(leftButtonItem: .documentPicker)
#if targetEnvironment(simulator)
            toolbarView.setUpLeftButton2(leftButtonItem: .flashLight)
            
#else
            if viewModel.hasDeviceTorch {
                toolbarView.setUpLeftButton2(leftButtonItem: .flashLight)
            }
#endif
            toolbarView.layoutMargins.top = .space_24
            toolbarView.delegate = self
            toolbarView.rightButtonVoiceOverSettings = viewModel.closeVoiceOverOptions
            toolbarView.leftButton2VoiceOverSettings = viewModel.currentTorchVoiceOverOptions
            toolbarView.leftButtonVoiceOverSettings = viewModel.documentPickerVoiceOverOptions

        } else {
            toolbarView.state = .cancel
            toolbarView.leftButton.isHidden = true
#if targetEnvironment(simulator)
            toolbarView.setUpRightButton(rightButtonItem: .flashLight)
            
#else
            if viewModel.hasDeviceTorch {
                toolbarView.setUpRightButton(rightButtonItem: .flashLight)
            }
#endif
            toolbarView.layoutMargins.top = .space_24
            toolbarView.delegate = self
            toolbarView.primaryButtonVoiceOverSettings = viewModel.closeVoiceOverOptions
            toolbarView.rightButtonVoiceOverSettings = viewModel.currentTorchVoiceOverOptions
        }
    }
    
    private func removeScanView() {
        scanViewController?.view.removeFromSuperview()
        scanViewController = nil
    }

    func pickingWasCancelled() {
        dismiss(animated: true)
        viewModel.mode = .scan
    }
}

extension ScanViewController: ScanViewModelDelegate {
    
    func selectFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    func selectImages() {
        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 0
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.mediaTypes = ["public.image"]
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            pickerController.sourceType = .photoLibrary
            present(pickerController, animated: true)
        }
    }

    func viewModelDidChange() {
        switch viewModel.mode {
        case .scan:
            configureScanView()
        case .selection:
            removeScanView()
        }
    }
}

// MARK: - CustomToolbarViewDelegate

extension ScanViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .cancelButton:
            viewModel.cancel()
        case .flashLight:
            viewModel.toggleFlashlight()
            toolbarView.leftButton2VoiceOverSettings = viewModel.currentTorchVoiceOverOptions
        case .documentPicker:
            viewModel.documentPicker()
        default:
            return
        }
    }
}

// MARK: - ScannerDelegate

extension ScanViewController: ScannerDelegate {
    public func result(with value: Swift.Result<String, ScanError>) {
        viewModel.onResult(value)
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension ScanViewController: ModalInteractiveDismissibleProtocol {
    public func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }
    
    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pickingWasCancelled()
    }
}

// MARK: - UIDocumentPickerDelegate

extension ScanViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel.documentPicked(at: urls)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        viewModel.documentPicked(at: [url])
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14, *)
extension ScanViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.isEmpty {
            pickingWasCancelled()
        }
        // Get the reference of itemProvider from results
        var images = Array<UIImage>()
        results.forEach { result in
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        guard let image = image as? UIImage else { return }
                        images.append(image)
                        print("images.count \(images.count) results.count \(results.count)")
                        if images.count == results.count {
                            self.viewModel.imagePicked(images: images)
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ScanViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        viewModel.imagePicked(images: [image])
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickingWasCancelled()
    }
}
