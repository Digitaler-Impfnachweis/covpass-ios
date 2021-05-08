//
//  CertificateRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon
import Scanner

protocol CertificateRouterProtocol: RouterProtocol {
    func showCertificates(_ certificates: [ExtendedCBORWebToken])
    func showProof() -> Promise<Void>
    func scanQRCode() -> Promise<ScanResult>
    func showAppInformation()
    func showErrorDialog()
}
