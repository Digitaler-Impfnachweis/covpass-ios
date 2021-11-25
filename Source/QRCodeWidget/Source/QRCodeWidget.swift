//
//  QRCodeWidget.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import SwiftUI
import WidgetKit


@main
struct QRCodeWidget: Widget {
    let kind: String = "com.ibm.ega.VaccinationPass.widget.qr"
    let repository = VaccinationRepository.create()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QRCodeProvider(repository: repository)) { entry in
            QRCodeWidgetView(entry: entry)
        }
        .configurationDisplayName("cert_app_name")
        .description("qr_widget_description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


struct QRCodeProvider: TimelineProvider {
    private var repository: VaccinationRepositoryProtocol
    
    init(repository: VaccinationRepositoryProtocol) {
        self.repository = repository
    }
    
    func placeholder(in context: Context) -> QRCodeWidgetEntry {
        QRCodeWidgetEntry.mock()
    }

    func getSnapshot(in context: Context, completion: @escaping (QRCodeWidgetEntry) -> ()) {
        createEntry(date: Date())
            .done { entry in
                completion(entry)
            }
            .catch { error in
                completion(QRCodeWidgetEntry.empty())
            }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        createEntry(date: Date())
            .done { entry in
                let timeline = Timeline(entries: [entry], policy: .after(entry.qrCodeExpiryDate ?? Date()))
                completion(timeline)
            }
            .catch { error in
                let emptyEntry = QRCodeWidgetEntry.empty()
                let timeline = Timeline(entries: [emptyEntry], policy: .after(emptyEntry.qrCodeExpiryDate ?? Date()))
                completion(timeline)
            }
    }
    
    private func createEntry(date: Date) -> Promise<QRCodeWidgetEntry> {
        repository.getCertificateList()
            .map { certificates -> [ExtendedCBORWebToken] in
                return CertificateSorter.sort(certificates.certificates)
            }
            .firstValue
            .map { activeCertificate in
                return QRCodeWidgetEntry(date: date,
                                  qrCodeData: activeCertificate.vaccinationQRCodeData,
                                  qrCodeExpiryDate: activeCertificate.vaccinationCertificate.exp)
            }
    }        
}
