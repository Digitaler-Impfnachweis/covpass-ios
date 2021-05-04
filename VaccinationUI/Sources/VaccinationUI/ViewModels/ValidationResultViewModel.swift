//
//  StartOnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationCommon

enum Result {
    case full
    case partial
    case error
}

open class ValidationResultViewModel: BaseViewModel {
    let router: ValidationResultRouterProtocol

    public init(
        router: ValidationResultRouterProtocol,
        certificate: ValidationCertificate?) {
        self.router = router
        self.certificate = certificate
    }

    private var result: Result {
        guard let cert = certificate else {
            return .error
        }
        return cert.partialVaccination ? .partial : .full
    }
    private var certificate: ValidationCertificate?

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
            return certificate?.name
        case .error:
            return "Impfnachweis nicht gefunden"
        }
    }

    open var nameBody: String? {
        switch result {
        case .full, .partial:
            if let date = certificate?.birthDate {
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

    // MARK: - Methods

    func cancel() {
        router.showStart()
    }

    func scanNextCertifcate() {
        firstly {
            router.scanQRCode()
        }
        .cauterize()
    }
}

