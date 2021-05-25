//
//  ScannerViewController.swift
//
//
//  Created by Daniel on 29.03.2021.
//

import AVFoundation
import Foundation
import UIKit

#if targetEnvironment(simulator)
    public class ScannerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var coordindator: ScannerCoordinator?

        override public func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0

            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            label.textAlignment = .center
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Or tap here to select a custom image", for: .normal)
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.setTitleColor(UIColor.gray, for: .highlighted)
            button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)

            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 50
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(button)

            view.addSubview(stackView)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

        override public func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
            guard let simulatedData = coordindator?.simulatedData else {
                print("Simulated Data Not Provided!")
                return
            }

            coordindator?.found(code: simulatedData)
        }

        @objc func openGallery(_: UIButton) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }

        public func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let qrcodeImg = info[.originalImage] as? UIImage {
                let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
                let ciImage = CIImage(image: qrcodeImg)!
                var qrCodeLink = ""

                let features = detector.features(in: ciImage)
                for feature in features as! [CIQRCodeFeature] {
                    qrCodeLink += feature.messageString!
                }

                if qrCodeLink == "" {
                    coordindator?.didFail(reason: .badOutput)
                } else {
                    coordindator?.found(code: qrCodeLink)
                }
            } else {
                print("Something went wrong")
            }
            dismiss(animated: true, completion: nil)
        }
    }
#else

    public class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var coordindator: ScannerCoordinator?

        override public func viewDidLoad() {
            super.viewDidLoad()

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateOrientation),
                                                   name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                                   object: nil)

            view.backgroundColor = UIColor.black
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                coordindator?.didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(coordindator, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = coordindator?.codeTypes
            } else {
                coordindator?.didFail(reason: .badOutput)
                return
            }
        }

        override public func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }

        @objc func updateOrientation() {
            var orientation: UIInterfaceOrientation = .portrait
            if #available(iOS 13.0, *) {
                orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait
            } else {
                orientation = UIApplication.shared.statusBarOrientation
            }

            if #available(iOS 13.0, *) {
                guard let connection = captureSession.connections.last, connection.isVideoOrientationSupported else { return }
                connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
            } else {
                // Fallback on earlier versions
                guard let connection = previewLayer.connection, connection.isVideoOrientationSupported else { return }
                connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
            }
        }

        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateOrientation()
        }

        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            if captureSession?.isRunning == false {
                captureSession.startRunning()
            }
        }

        override public func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            if captureSession?.isRunning == true {
                captureSession.stopRunning()
            }

            NotificationCenter.default.removeObserver(self)
        }

        override public var prefersStatusBarHidden: Bool { true }

        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    }
#endif
