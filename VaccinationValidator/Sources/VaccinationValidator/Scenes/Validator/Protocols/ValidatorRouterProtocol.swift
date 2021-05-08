//
//  ValidatorRouterProtocol.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon
import Scanner

protocol ValidatorRouterProtocol: RouterProtocol {
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken)
    func showAppInformation()
}
