//
//  TopViewExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Use this method in order to show a new view on top of current view that is blurred out
    /// - Parameters:
    ///   - radius: Blur radius for base view
    ///   - topView: A view that can show up on top of current view - usually contains an animation
    ///   - binding: Binding value that determines if the `topView` is visible or not
    /// - Returns: A new view that alters current one by adding blurr and `topView` on top
    func showBlurView<TopView: View>(with radius: CGFloat = 20, and topView: TopView, when binding: Binding<Bool>) -> some View {
        modifier(TopViewModifier(destination: topView, blurRadius: radius, binding: binding))
    }
    
    /// Use this method in order to show certain `LoadingView` on top of current view that is blurred out
    /// - Parameter binding: Binding value determinating if the view is visible or not
    /// - Returns: A new view that alters current one by adding blurr and `LodaingView` on top
    func showLoadingView(when binding: Binding<Bool>, color: Color = .blue) -> some View {
        showBlurView(and: LoadingView(color: color), when: binding)
    }
}
