//
//  QRCodeWidgetEntry.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import WidgetKit
import CovPassCommon

struct QRCodeWidgetEntry: TimelineEntry {
    var date: Date
    var qrCodeData: String?
    var qrCodeExpiryDate: Date?
}

extension QRCodeWidgetEntry {
    static func empty() -> QRCodeWidgetEntry {
        QRCodeWidgetEntry(date: Date(), qrCodeData: nil, qrCodeExpiryDate: nil)
    }
    
    static func mock(date: Date = Date()) -> QRCodeWidgetEntry {
        let mockToken = CBORWebToken.mockVaccinationCertificate
        let mockQRData = try? mockToken.generateQRCodeData()
        let expiryDate = Date().addingTimeInterval(86400) // Expire in 24 hours
        
        return QRCodeWidgetEntry(date: date, qrCodeData: mockQRData, qrCodeExpiryDate: expiryDate)
    }
}
