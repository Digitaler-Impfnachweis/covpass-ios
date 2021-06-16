//
//  DotPulseActivityIndicator.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

/**
 This class can be created in two different ways:
 • using init(frame) method, when creating the UI in code
 • Add a UIView to your view in the storyboard, and change its class to DotPulseActivityIndicator

 - Note: Height of the UIView should be the diameter of the dot(circle) pluse the paddings
 Width of the UIView should be greater than the following
 (numberOfDots * dotSize) + [(numberOfDots - 1) * spacingToDotWidthRatio * dotSize] + 2* padding,
 where dotSize = diameter of the dot(circle)

 Next, you have to set up the activity indicator by setting the following properties
 • Color of the dots
 • Padding of the dots to the container
 • number of Dots

 - To start the animation, call the method "startAnimating". Then, the dots appear on the screen and start animating.
 - To stop the animation, call the method "stopAnimating". Then, the dots stop animating and disappear from the screen.
 */

public final class DotPulseActivityIndicator: UIView {
    enum Defaults {
        /// Default color of activity indicator.
        static let color: UIColor = .brandAccent70
        /// Default padding (0)
        static let padding: CGFloat = 0
    }

    /// Color of activity indicator view.
    @IBInspectable public var color: UIColor = DotPulseActivityIndicator.Defaults.color

    // Padding of activity indicator view.
    @IBInspectable public var padding: CGFloat = DotPulseActivityIndicator.Defaults.padding

    /// An Int value that controls how many dots need to be shown in the activity indicator
    @IBInspectable public var numberOfDots: Int = 3

    /// A Boolean value indicating whether the activity indicator is currently running its animation.
    public private(set) var isAnimating: Bool = false

    /// A CGFloat value indicating the ratio of the spacing to the dot width
    private static let spacingToDotWidthRatio: CGFloat = 10.0 / 16.0

    /// A CGFloat value indicating the scale factor for the dot scale animation
    private static let dotAnimationScaleFactor: CGFloat = 12.0 / 16.0

    /// A CGFlaot value indicating the alpha factor of the dot color animation
    private static let dotAnimationAlpha: CGFloat = 0.4
    /**
     Returns an object initialized from data in a given unarchiver.
     self, initialized using the data in decoder.

     - parameter decoder: an unarchiver object.

     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }

    /**
     Create an activity indicator view

     - parameter frame: view's frame
     - parameter color: color of activity indicator view.
     - parameter padding: padding of activity indicator view.

     - returns: The activity indicator view
     */

    public init(frame: CGRect, color: UIColor? = nil, padding: CGFloat? = nil) {
        self.color = color ?? DotPulseActivityIndicator.Defaults.color
        self.padding = padding ?? DotPulseActivityIndicator.Defaults.padding
        super.init(frame: frame)
        backgroundColor = .clear
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }

    /**
     Start animating
     */
    public final func startAnimating() {
        isHidden = false
        isAnimating = true
        drawDotsAndStartAnimation()
    }

    /**
     Stop animating
     */
    public final func stopAnimating() {
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }

    private func drawDotsAndStartAnimation() {
        layer.sublayers = nil
        let rect = frame.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))

        // Given the number of dots, the size of the dot is calculated as below:
        // sizeOfDot * numberOfDots + spacing * (numberOfDots - 1) = rect.width
        let sizeOfDotBasedOnContainerWidth = rect.size.width / (CGFloat(numberOfDots) + (DotPulseActivityIndicator.spacingToDotWidthRatio * CGFloat(numberOfDots)) - DotPulseActivityIndicator.spacingToDotWidthRatio)

        let dotSize: CGFloat = min(sizeOfDotBasedOnContainerWidth, rect.size.height)
        let spacing: CGFloat = DotPulseActivityIndicator.spacingToDotWidthRatio * dotSize

        let originX: CGFloat = (layer.bounds.size.width - dotSize * CGFloat(numberOfDots) - spacing * CGFloat(numberOfDots - 1)) / 2

        let eachPulseDuration: CFTimeInterval = 0.6
        let animation = setupAnimation(with: eachPulseDuration)
        let beginTime = CACurrentMediaTime()
        for idx in 0 ..< numberOfDots {
            let origin = CGPoint(x: originX + dotSize * CGFloat(idx) + spacing * CGFloat(idx),
                                 y: (layer.bounds.size.height - dotSize) / 2)
            let dotLayer = DotLayer(at: origin, width: dotSize * DotPulseActivityIndicator.dotAnimationScaleFactor, color: color)
            animation.beginTime = beginTime + Double(idx) * eachPulseDuration * 0.5
            dotLayer.add(animation, forKey: "animation")
            layer.addSublayer(dotLayer)
        }
    }

    private final func setupAnimation(with eachPulseDuration: CFTimeInterval) -> CAAnimationGroup {
        // Animation setup
        // The following values are the design requirements for the animation
        let dotScaleFactor: CGFloat = DotPulseActivityIndicator.dotAnimationScaleFactor
        let dotAlpha: CGFloat = DotPulseActivityIndicator.dotAnimationAlpha
        let duration: CFTimeInterval = Double(numberOfDots) * eachPulseDuration * 0.5

        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")

        scaleAnimation.keyTimes = [0, eachPulseDuration * 0.5, eachPulseDuration] as [NSNumber]
        scaleAnimation.values = [CGFloat(1.0), 1.0 / dotScaleFactor, CGFloat(1.0)]
        scaleAnimation.duration = duration
        scaleAnimation.autoreverses = true

        // Opacity animation
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")

        opacityAnimaton.keyTimes = [0, eachPulseDuration * 0.5, eachPulseDuration] as [NSNumber]
        opacityAnimaton.values = [dotAlpha, CGFloat(1.0), dotAlpha]
        opacityAnimaton.duration = duration

        // Animation Group
        let animation = CAAnimationGroup()

        animation.animations = [scaleAnimation, opacityAnimaton]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        return animation
    }
}
