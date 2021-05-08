//
//  ValidationResultRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationUI

protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func scanQRCode() -> Promise<ScanResult>
}
