//
//  CardCollectionViewCell.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class CardCollectionViewCell: UICollectionViewCell {
    public var viewModel: CardViewModel?
}

extension CardCollectionViewCell: ViewModelDelegate {
    @objc public func viewModelDidUpdate() {}
    @objc public func viewModelUpdateDidFailWithError(_ error: Error) {}
}
