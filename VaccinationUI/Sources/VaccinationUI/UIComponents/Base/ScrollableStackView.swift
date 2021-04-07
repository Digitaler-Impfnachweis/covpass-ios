//
//  ScrollableStackView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//
//  StackView Settings
//  Axis            Vertical
//  Alignment       Fill
//  Distribution    Fill
//

import UIKit

@IBDesignable
public class ScrollableStackView: UIStackView {
    private var spacerView: Spacer?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        findBottomSpacer()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        findBottomSpacer()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // View adaptation
        computeSubviewMargins()
        fillScollView()
    }

    // MARK: - Private Helpers

    private func findBottomSpacer() {
        spacerView = arrangedSubviews.reversed().first { type(of: $0) == Spacer.self } as? Spacer
    }

    // The _idea_ of this class/method is that the spacer view is shown,
    // if the stack view is smaller than the containing scroll view.
    // The spacer has a lower than default content hugging priority and
    // content compression resistance. So it's supposed to take up any
    // excess space, pushing any following elements to the bottom of the
    // screen.
    //
    // Unfortunately this logic is flawed: the stack view will still try
    // to be as small as possible and there's no constraint stretching it
    // to the scroll views height. To do so we'd need a
    // `stackView.height >= scrollViewContainer.height` constraint (NOT a
    // `superview.height` constraint, as this would refer to the content
    // size of the scroll view). In that case the spacer view could always
    // be visible and this method could be removed.
    //
    // So what this method _actually_ does is hide the bottom most spacer
    // if the stack view content is larger than the scroll view frame.
    // Leaving this method in here for now because some view might rely on
    // this. Hopefully we can remove this entirely in the future.
    private func fillScollView() {
        // Make the stackview adapt its parent height
        guard let scrollView = superview as? UIScrollView else {
            return
        }

        spacerView?.isHidden = frame.height > scrollView.frame.height
    }

    // MARK: - Marginable Subviews

    private func computeSubviewMargins() {
        for index in 0 ..< arrangedSubviews.count {
            if let marginableView = arrangedSubviews[index] as? Marginable {
                var neighbor: MarginableXibView?
                var neighborIndex = index

                while neighborIndex < arrangedSubviews.count {
                    neighbor = self.neighbor(at: neighborIndex)

                    if neighbor != nil {
                        break
                    }

                    neighborIndex += 1
                }

                marginableView.computeMargins(at: index, and: neighbor)
            }
        }
    }

    private func neighbor(at index: Int) -> MarginableXibView? {
        if (index + 1) >= arrangedSubviews.count {
            return nil
        }

        if let nextView = arrangedSubviews[index + 1] as? Marginable, !nextView.isHidden {
            return nextView as? MarginableXibView
        }

        if let spacer = arrangedSubviews[index + 1] as? Spacer, !spacer.isHidden {
            return neighbor(at: index + 1)
        }

        return nil
    }
}
