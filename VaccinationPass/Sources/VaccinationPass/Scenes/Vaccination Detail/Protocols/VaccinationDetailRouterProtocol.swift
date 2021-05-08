//
//  CertificateDetailRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI

public protocol VaccinationDetailRouterProtocol: DialogRouterProtocol {
    func showScanner() -> Promise<ScanResult>
    func showCertificateOverview()
    func showErrorDialog()
}
