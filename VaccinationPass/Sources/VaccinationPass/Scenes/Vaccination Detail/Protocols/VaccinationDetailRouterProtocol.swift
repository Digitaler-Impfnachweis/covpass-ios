//
//  CertificateDetailRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationUI

protocol VaccinationDetailRouterProtocol: DialogRouterProtocol {
    func showScanner() -> Promise<ScanResult>
    func showCertificateOverview() -> Promise<Void>
    func showErrorDialog()
}
