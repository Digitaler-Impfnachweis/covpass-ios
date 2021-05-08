//
//  CertificateRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import Scanner
import UIKit
import VaccinationCommon
import VaccinationUI

protocol CertificateRouterProtocol: RouterProtocol {
    func showCertificates(_ certificates: [ExtendedCBORWebToken])
    func showProof() -> Promise<Void>
    func scanQRCode() -> Promise<ScanResult>
    func showAppInformation()
    func showErrorDialog()
}
