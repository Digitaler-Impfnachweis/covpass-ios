//
//  BaseViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol BaseViewModel {
    var image: UIImage? { get }
    var title: String { get }
    var info: String { get }
    var imageAspectRatio: CGFloat { get }
    var imageWidth: CGFloat { get }
    var imageHeight: CGFloat { get }
    var imageContentMode: UIView.ContentMode { get }
    var headlineFont: UIFont { get }
    var headlineColor: UIColor { get}
    var paragraphBodyFont: UIFont { get }
    var backgroundColor: UIColor { get }
}
