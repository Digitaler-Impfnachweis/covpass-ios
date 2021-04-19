//
//  MockQRCoder.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import VaccinationCommon

class MockQRCoder: QRCoderProtocol {
    
    func parse(_ payload: String, completion: ((Error) -> Void)?) -> String? {
        payload
    }
}
