//
//  EmptyQRCodeView.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import SwiftUI
import WidgetKit

struct EmptyQRCodeView: View {
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack {
            BrandHeaderView()
            
            Spacer()
            
            Text("qr_widget_nothing_to_show")
                .foregroundColor(.onBrandBase)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
        .padding(family == .systemLarge ? 12 : 10)
    }
}

struct EmptyQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
