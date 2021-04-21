//
//  HeadlineViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol HeadlineViewModel {
    var headlineTitle: String { get }
    var headlineButtonInsets: UIEdgeInsets { get }
    var headlineFont: UIFont { get }
    var headlineButtonImage: UIImage? { get }
}

