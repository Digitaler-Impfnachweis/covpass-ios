//
//  StartOnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationCommon

enum Result {
    case full
    case partial
    case error
}

open class ValidationResultViewModel: BaseViewModel {

    public init(certificate: CBORWebToken?) {
        self.certificate = certificate
    }

    private var result: Result {
        guard let cert = certificate else {
            return .error
        }
        return cert.hcert.dgc.fullImmunization ? .full : .partial
    }
    private var certificate: CBORWebToken?

    open var icon: UIImage? {
        switch result {
        case .full:
            return UIImage(named: "result_success", in: UIConstants.bundle, compatibleWith: nil)
        case .partial, .error:
            return UIImage(named: "result_error", in: UIConstants.bundle, compatibleWith: nil)
        }
    }

    open var resultTitle: String {
        switch result {
        case .full:
            return "Impfschutz gültig"
        case .partial:
            return "Impfschutz nicht vollständig"
        case .error:
            return "Prüfung nicht erfolgreich"
        }
    }

    open var resultBody: String {
        switch result {
        case .full:
            return "Gleichen Sie jetzt folgende Daten mit dem Personalausweis oder Reisepass ab."
        case .partial:
            return "Das geprüfte Zertifikat weist keine vollständige Impfung nach."
        case .error:
            return "Das kann zwei Gründe haben:"
        }
    }

    open var nameTitle: String? {
        switch result {
        case .full, .partial:
            return certificate?.hcert.dgc.nam.fullName
        case .error:
            return "Impfnachweis nicht gefunden"
        }
    }

    open var nameBody: String? {
        switch result {
        case .full, .partial:
            if let date = certificate?.hcert.dgc.dob {
                return "Geboren am \(DateUtils.displayDateFormatter.string(from: date))"
            }
            return nil
        case .error:
            return "Es sind keine Daten auf dem Prüfzertifikat gespeichert. Sollten Sie sich im Offline-Modus befinden, aktualisieren Sie die App."
        }
    }

    var closeButtonImage: UIImage? {
        .close
    }

    // MARK - PopupRouter

    let height: CGFloat = 650
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true

    //
    public var image: UIImage?

    public var title: String = ""

    public var info: String = ""

    public var backgroundColor: UIColor = UIColor.black
}

