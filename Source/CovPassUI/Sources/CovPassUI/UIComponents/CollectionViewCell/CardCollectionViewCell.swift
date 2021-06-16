//
//  CardCollectionViewCell.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class CardCollectionViewCell: UICollectionViewCell {
    public var viewModel: CardViewModel?
}

extension CardCollectionViewCell: ViewModelDelegate {
    @objc public func viewModelDidUpdate() {}
    @objc public func viewModelUpdateDidFailWithError(_: Error) {}
}
