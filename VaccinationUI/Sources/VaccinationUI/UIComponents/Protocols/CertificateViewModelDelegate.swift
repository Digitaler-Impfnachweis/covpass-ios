//
//  CertificateViewModelDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol CertificateViewModelDelegate: ViewModelDelegate {
    func favoriteButtonTapped(for indexPath: IndexPath)
    func detailsButtonTapped(for indexPath: IndexPath)
}
