//
//  CertificateViewModelDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

protocol CertificateViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidUpdateFavorite()
    func viewModelDidAddCertificate()
    func viewModelDidDeleteCertificate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
