//
//  BaseCardCollectionViewCell.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class BaseCardCollectionViewCell: UICollectionViewCell {
    public var onAction: (() -> Void)?
    public var onFavorite: (() -> Void)?
}

// MARK: - CellConfigutation

extension BaseCardCollectionViewCell: CellConfigutation {
    public typealias T = BaseCertifiateConfiguration
    
    public func configure(with configuration: T) {
        // ...
    }
}
