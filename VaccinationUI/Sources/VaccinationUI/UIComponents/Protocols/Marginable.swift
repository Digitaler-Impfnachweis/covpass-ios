//
//  Styleable.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol Marginable {
    var viewType: UIView.Type { get }
    var margins: [Margin] { get }
    var shouldAutomaticallySetTopMargin: Bool { get }
    var isHidden: Bool { get }

    func computeMargins(at row: Int, and neighbor: Marginable?)
    func setMargin(_ margin: Margin)
}

extension Marginable {
    public func computeMargins(at row: Int, and neighbor: Marginable?) {
        var currentRow = row

        if shouldAutomaticallySetTopMargin, currentRow != 0 {
            // change top margin to 0px for every element except the first one
            let topMargin = PositionMargin(constant: 0, position: row, type: .top)
            setMargin(topMargin)
        }

        if neighbor == nil {
            // current element has no neighbor = last element
            currentRow = -1
        }

        for margin in margins {
            if let relatedViewMargin = margin as? RelatedViewMargin {
                if neighbor != nil, neighbor?.viewType == relatedViewMargin.relatedViewType {
                    setMargin(margin)
                }
            }

            if let positionMargin = margin as? PositionMargin, positionMargin.position == currentRow || positionMargin.position == row {
                // Note: View can be on first and last position at the same time
                setMargin(margin)
            }
        }
    }
}
