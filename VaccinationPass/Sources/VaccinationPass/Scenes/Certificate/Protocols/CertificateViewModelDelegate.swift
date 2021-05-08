//
//  File.swift
//
//
//  Created by Sebastian Maschinski on 07.05.21.
//

import Foundation

protocol CertificateViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidUpdateFavorite()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
