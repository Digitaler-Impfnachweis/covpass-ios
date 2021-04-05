//
//  CertificateViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

public class CertificateViewController: UIViewController {
    
    @IBOutlet public var partialCardView: PartialCertifiateCardView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        partialCardView.actionButton.title = "2. Impfung hinzufügen"
    }
}
