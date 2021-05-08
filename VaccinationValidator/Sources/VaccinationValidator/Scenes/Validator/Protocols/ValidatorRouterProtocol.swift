//
//  ValidatorRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import Scanner
import UIKit
import VaccinationCommon
import VaccinationUI

protocol ValidatorRouterProtocol: RouterProtocol {
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken?)
    func showAppInformation()
}
