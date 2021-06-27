import CovPassCommon
import SwiftUI
import WidgetKit

struct CovPassCertificateProvider: TimelineProvider {
    let favoriteRepository: VaccinationFavoriteRepositoryProtocol

    init(favoriteRepository: VaccinationFavoriteRepositoryProtocol = VaccinationFavoriteRepository()) {
        self.favoriteRepository = favoriteRepository
    }

    func placeholder(in _: Context) -> CovPassCertificateEntry {
        .init(date: .init(), qrCode: nil)
    }

    func getSnapshot(in _: Context, completion: @escaping (CovPassCertificateEntry) -> Void) {
        guard let token = try? favoriteRepository.get() else {
            completion(.init(
                date: .init(),
                qrCode: nil
            ))
            return
        }
        completion(.init(
            date: .init(),
            qrCode: token.vaccinationQRCodeData
        ))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<CovPassCertificateEntry>) -> Void) {
        guard let token = try? favoriteRepository.get() else {
            completion(.init(entries: [
                .init(
                    date: .init(),
                    qrCode: nil
                )
            ], policy: .never))
            return
        }
        let currentDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .hour,
            value: 12,
            to: currentDate
        )!
        let timeline = Timeline<CovPassCertificateEntry>(
            entries: [
                .init(
                    date: .init(),
                    qrCode: token.vaccinationQRCodeData
                )
            ],
            policy: .after(refreshDate)
        )
        completion(timeline)
    }
}
