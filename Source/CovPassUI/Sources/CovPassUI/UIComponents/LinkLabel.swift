//
//  LinkLabel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class LinkLabel: XibView {
    @IBOutlet public var textableView: UITextView!
    public var linkCallback: ((URL) -> Void)?

    override public func initView() {
        super.initView()
        textableView.delegate = self
        textableView.isScrollEnabled = false
    }

    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedText
        }
        set {
            guard let nv = newValue else {
                textableView.attributedText = nil
                return
            }
            textableView.attributedText = NSMutableAttributedString(attributedString: nv).replaceLink()
        }
    }
}

extension LinkLabel: UITextViewDelegate {
    public func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        if let callback = linkCallback {
            callback(URL)
        } else {
            UIApplication.shared.open(URL)
        }
        return false
    }
}
