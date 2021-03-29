//
//  ScanViewController.swift
//  VaccinationPassApp
//
//  Created by Daniel on 29.03.2021.
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import Scanner

class ScanViewController: UIViewController {
    
    var scanViewController: ScannerViewController?
    
    @IBAction func showScanner(_ sender: UIButton) {
        scanViewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, simulatedData: "This is Gabriela", delegate: self)
        present(scanViewController ?? UIViewController(), animated: true, completion: nil)
    }
}

extension ScanViewController: ScannerDelegate {
    func result(with value: Result<String, ScanError>) {
        print(value)
        scanViewController?.dismiss(animated: true, completion: nil)
    }
}
