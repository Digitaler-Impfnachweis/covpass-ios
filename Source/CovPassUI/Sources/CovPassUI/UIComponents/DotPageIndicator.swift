//
//  DotPageIndicator.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol DotPageIndicatorDelegate: AnyObject {
    func dotPageIndicator(_ dotPageIndicator: DotPageIndicator, didTapDot index: Int)
}

/// An indicator that shows multiple dots indicating the number of pages that are displayed and highlights the position of the current one.
public class DotPageIndicator: UIView {
    /// An Int value that controls how many dots need to be shown in the page indicator.
    @IBInspectable public var numberOfDots: Int = 3 {
        didSet {
            setupView()
        }
    }

    @IBInspectable public var unselectedColor: UIColor = .clear
    @IBInspectable public var selectedColor: UIColor = .brandAccent70
    public var borderColor: UIColor = .brandAccent

    private var dotSize: CGFloat = 10
    private var dotPadding: CGFloat = 8.0
    var dots: [UIButton] = []
    var selectedDotIndex: Int = 0
    private var dotContentView: UIStackView!

    public weak var delegate: DotPageIndicatorDelegate?

    init(frame: CGRect, numberOfDots: Int, color: UIColor? = nil) {
        self.numberOfDots = numberOfDots
        unselectedColor = color ?? .brandAccent20
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    public func selectDot(withIndex index: Int) {
        // If it is already selected, then there is no need to select it again
        guard selectedDotIndex != index else { return }

        deselectSelectedDot()

        let newDot = dots[index]
        UIView.animate(withDuration: 0.4) {
            newDot.backgroundColor = self.selectedColor
        }

        selectedDotIndex = index
    }

    func deselectSelectedDot() {
        guard selectedDotIndex < numberOfDots else { return }
        let selectedDot = dots[selectedDotIndex]
        UIView.animate(withDuration: 0.4) {
            selectedDot.backgroundColor = self.unselectedColor
        }
    }

    private func setupView() {
        layoutMargins = .zero
        backgroundColor = .clear
        if dotContentView != nil {
            dotContentView.removeFromSuperview()
        }

        updateDots()
        dotContentView = UIStackView(arrangedSubviews: dots)
        dotContentView.axis = .horizontal
        dotContentView.distribution = .fillEqually
        dotContentView.spacing = dotPadding
        dotContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dotContentView)
        NSLayoutConstraint.activate([
            dotContentView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            dotContentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            dotContentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func updateDots() {
        for button in dots {
            button.removeFromSuperview()
        }
        dots = []

        for i in 0 ..< numberOfDots {
            let dot = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: dotSize, height: dotSize))
            dot.round(corners: .allCorners, with: dotSize / 2)
            dot.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)

            if i == selectedDotIndex {
                dot.backgroundColor = selectedColor
            } else {
                dot.backgroundColor = unselectedColor
            }
            dot.layer.borderColor = borderColor.cgColor
            dot.layer.borderWidth = 1
            dot.layer.cornerRadius = dotSize / 2

            dot.setConstant(size: CGSize(width: dotSize, height: dotSize))
            dots.append(dot)
        }

        updateAccessibilityLabel()
    }

    @objc func didTapButton(_ sender: UIButton) {
        for (index, dot) in dots.enumerated() {
            if sender.isEqual(dot) {
                delegate?.dotPageIndicator(self, didTapDot: index)
                selectDot(withIndex: index)
            }
        }
    }

    // MARK: - Accessibility

    private func updateAccessibilityLabel() {
        for (index, dot) in dots.enumerated() {
            dot.accessibilityLabel = String(format: "accessibility_page_indicator".localized, index + 1, dots.count)
            dot.accessibilityIdentifier = "page-indicator-\(index)"
        }
    }
}
