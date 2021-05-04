//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 04.05.21.
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
