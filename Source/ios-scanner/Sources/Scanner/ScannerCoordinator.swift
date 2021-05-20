//
//  ScannerCoordinator.swift
//  
//
//  Created by Daniel on 29.03.2021.
//

import Foundation
import AVFoundation

public class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
   
    // MARK: - Internal
    
    var codesFound: Set<String>
    var isFinishScanning = false
    var lastTime = Date(timeIntervalSince1970: 0)
    
    // MARK: - Public
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public let scanMode: ScanMode
    public let scanInterval: Double
    public var simulatedData = ""
    public weak var delegate: ScannerDelegate?
    
    // MARK: - Init

    public init(codeTypes: [AVMetadataObject.ObjectType], scanMode: ScanMode = .once, scanInterval: Double = 2.0, simulatedData: String = "") {
        self.codeTypes = codeTypes
        self.scanMode = scanMode
        self.scanInterval = scanInterval
        self.simulatedData = simulatedData
        self.codesFound = Set<String>()
    }


    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            guard isFinishScanning == false else { return }

            switch scanMode {
            case .once:
                found(code: stringValue)
                // make sure we only trigger scan once per use
                isFinishScanning = true
            case .oncePerCode:
                if !codesFound.contains(stringValue) {
                    codesFound.insert(stringValue)
                    found(code: stringValue)
                }
            case .continuous:
                if isPastScanInterval() {
                    found(code: stringValue)
                }
            }
        }
    }

    func isPastScanInterval() -> Bool {
        return Date().timeIntervalSince(lastTime) >= scanInterval
    }
    
    func found(code: String) {
        lastTime = Date()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        delegate?.result(with: .success(code))
    }

    func didFail(reason: ScanError) {
        delegate?.result(with: .failure(reason))
    }
}
