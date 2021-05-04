//
//  ValidationResultRouterProtocol.swift
//
//
//  Created by Sebastian Maschinski on 04.05.21.
//

import UIKit
import PromiseKit

public protocol ValidationResultRouterProtocol: RouterProtocol {
    func showStart()
    func scanQRCode() -> Promise<ScanResult>
}
