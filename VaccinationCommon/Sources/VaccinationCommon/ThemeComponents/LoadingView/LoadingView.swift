//
//  LoadingView.swift
//  
//
//   Copyright © 2021 IBM. All rights reserved.
//

import SwiftUI

public struct LoadingView: View {
    
    // MARK: - Private
    
    private let dotDelayMultiplyer = 2.0
    private let dotDelayValue = 0.20
    private let dotSize: CGFloat
    private let color: Color
    
    // MARK: - Init
    
    public init(dotSize: CGFloat = 30, color: Color) {
        self.dotSize = dotSize
        self.color = color
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack {
            DotView(size: dotSize, delay: 0, color: color)
            DotView(size: dotSize, delay: dotDelayValue, color: color)
            DotView(size: dotSize, delay: dotDelayMultiplyer * dotDelayValue, color: color)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(color: .blue)
    }
}
