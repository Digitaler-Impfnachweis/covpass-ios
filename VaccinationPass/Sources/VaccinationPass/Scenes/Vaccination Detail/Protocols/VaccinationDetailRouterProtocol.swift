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
    func showProof() -> Promise<Void>
    func showScanner() -> Promise<ScanResult>
    func showCertificateOverview()
    func showErrorDialog()
}
