//
//  CertificateViewController.swift
//  
//
//  Created by Daniel on 02.04.2021.
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
