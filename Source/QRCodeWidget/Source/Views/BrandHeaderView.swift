//
//  BrandHeaderView.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
import WidgetKit

struct BrandHeaderView: View {
    var body: some View {
        VStack(spacing: 8.0) {
            HStack(spacing: 8) {
                Image(uiImage: UIImage(named: "CovPass")!)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .shadow(color: .onBrandBase, radius: 6.0)
                
                Text("CovPass")
                    .foregroundColor(.onBrandBase)
                    .font(.sansBold(size: 20.0, relativeTo: .body))
            }
            
            Rectangle()
                .fill(Color.onBrandBase)
                .frame(height: 0.5)
        }
        .unredacted()
    }
}

struct BrandHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.brandBase
            
            BrandHeaderView()
                .padding()
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
