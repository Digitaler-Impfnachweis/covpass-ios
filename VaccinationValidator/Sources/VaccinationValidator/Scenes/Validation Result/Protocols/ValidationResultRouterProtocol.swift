//
//  ValidationResultRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI

public protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func scanQRCode() -> Promise<ScanResult>
}
