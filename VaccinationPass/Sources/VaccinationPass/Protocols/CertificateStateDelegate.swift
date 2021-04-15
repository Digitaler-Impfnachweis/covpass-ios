//
//  StateDelegate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol CertificateStateDelegate: class {
    func didUpdatedCertificate(state: CertificateState)
}
