//
//  CertificateDetailDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

protocol CertificateDetailDelegate: AnyObject {
    func didAddCertificate()
    func didAddFavoriteCertificate()
    func didDeleteCertificate()
}
