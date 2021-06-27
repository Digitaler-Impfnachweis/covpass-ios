import CovPassCommon
import SwiftUI
import WidgetKit

@main
struct CovPassCertificateWidget: Widget {
    let kind: String = "CovPassCertificateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CovPassCertificateProvider()
        ) { entry in
            CovPassCertificateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct CovPassCertificateWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CovPassCertificateWidgetEntryView(
                entry: CovPassCertificateEntry(
                    date: Date(),
                    qrCode: ""
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            CovPassCertificateWidgetEntryView(
                entry: CovPassCertificateEntry(
                    date: Date(),
                    qrCode: ""
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
