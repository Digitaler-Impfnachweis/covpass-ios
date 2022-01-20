//
//  CertResultCard.swift
//  
//
//  Created by Fatih Karakurt on 07.01.22.
//

import UIKit

public class CertResultCard: XibView {
    // MARK: - Properties
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titeLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var linkImageView: UIImageView!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet weak var subTitleStack: UIStackView!
    
    public var title: NSAttributedString? {
        didSet {
            self.titeLabel.attributedText = title
            self.titeLabel.isHidden = title == nil
        }
    }
    
    public var subtitle: NSAttributedString? {
        didSet {
            self.subTitleLabel.attributedText = subtitle
            self.subTitleLabel.isHidden = subtitle == nil
            self.subTitleStack.isHidden = subtitle == nil
        }
    }
    
    public var linkImage: UIImage? {
        didSet {
            self.linkImageView.image = linkImage
            self.linkImageView.isHidden = linkImage == nil
        }
    }
    
    public var resultImage: UIImage? {
        didSet {
            self.imageView.image = resultImage
        }
    }
    
    public var bottomText: NSAttributedString? {
        didSet {
            self.bottomLabel.attributedText = bottomText
        }
    }
    
    public var action: (() -> Void)? = nil

    // MARK: - Lifecycle
    
    public override func initView() {
        self.contentView?.layer.cornerRadius = 14
        self.contentView?.backgroundColor = UIColor.backgroundSecondary30
    }

    // MARK: - Methods
    
    @IBAction func linkTapped(_ sender: Any) {
        action?()
    }
}
