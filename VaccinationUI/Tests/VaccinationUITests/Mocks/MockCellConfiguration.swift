
//  MockCellConfiguration.swift
//
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import UIKit
import VaccinationUI
import VaccinationCommon

class MockCellConfiguration {
    static func noCertificateConfiguration() -> NoCertifiateConfiguration {
        return NoCertifiateConfiguration(title: "Title", subtitle: "Subtitle", image: UIImage())
    }
    
    static func qrCertificateConfiguration() -> QRCertificateConfiguration {
        let qrViewConfiguration = QrViewConfiguration(tintColor: .black, qrValue: NSUUID().uuidString, qrTitle: "Vorlaüfiger Impfnachweis", qrSubtitle: "Gultig bis 23.02.2023")
        return QRCertificateConfiguration(
            title: "Covid-19 Nachweis",
            subtitle: "Maximilian Mustermann",
            image: .starEmpty,
            stateImage: .halfShield,
            stateTitle: "Impfungen Anzeigen",
            stateAction: nil,
            headerImage: .starEmpty,
            headerAction: nil,
            backgroundColor: .onBackground50,
            qrViewConfiguration: qrViewConfiguration)
    }
}
