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

public protocol ValidatorRouterProtocol: RouterProtocol {
    func scanQRCode() -> Promise<Swift.Result<String, ScanError>>
    func showCertificate(_ certificate: ValidationCertificate)
}
