//
//  Scanner.swift
//  
//
//  Created by Daniel on 29.03.2021.
//

import Foundation
import AVFoundation

public struct Scanner {
    public static func viewController(codeTypes: [AVMetadataObject.ObjectType], scanMode: ScanMode = .once, scanInterval: Double = 2.0, simulatedData: String = "", delegate: ScannerDelegate?) -> ScannerViewController {
        let coordinator = ScannerCoordinator(codeTypes: codeTypes, scanMode: scanMode, scanInterval: scanInterval, simulatedData: simulatedData)
        coordinator.delegate = delegate
        let controller = ScannerViewController()
        controller.coordindator = coordinator
        return controller
    }
}
