//
//  QRCodeWidgetView.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
import WidgetKit

struct QRCodeWidgetView: View {
    var entry: QRCodeWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color.brandBase
            
            if let data = entry.qrCodeData, let uiImage = data.generateQRCode() {
                switch family {
                case .systemSmall:
                    buildSmallWidget(qrCodeImage: uiImage)
                    
                case .systemMedium:
                    buildMediumWidget(qrCodeImage: uiImage)
                    
                default:
                    buildLargeWidget(qrCodeImage: uiImage)
                }
            } else {
                EmptyQRCodeView()
            }
        }
    }
    
    var showMoreDetailsText: some View {
        Text("qr_widget_tap_for_more_details")
            .foregroundColor(.onBrandBase)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    func buildSmallWidget(qrCodeImage: UIImage) -> some View {
        buildQRCodeImage(uiImage: qrCodeImage)
            .scaledToFill()
            .padding(12)
    }
    
    @ViewBuilder
    func buildMediumWidget(qrCodeImage: UIImage) -> some View {
        HStack(spacing: 12) {
            buildQRCodeImage(uiImage: qrCodeImage)
            
            VStack {
                BrandHeaderView()
                
                Spacer()
                
                showMoreDetailsText
                
                Spacer()
            }
        }
        .padding(12)
    }
    
    @ViewBuilder
    func buildLargeWidget(qrCodeImage: UIImage) -> some View {
        VStack {
            BrandHeaderView()
            
            buildQRCodeImage(uiImage: qrCodeImage)
            
            showMoreDetailsText
        }
        .padding(12)
    }
    
    @ViewBuilder
    func buildQRCodeImage(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .interpolation(.none)
            .aspectRatio(1.0, contentMode: .fit)
    }
}

struct QRCodeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeWidgetView(entry: QRCodeWidgetEntry.mock())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.mock())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.mock())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        QRCodeWidgetView(entry: QRCodeWidgetEntry.empty())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
