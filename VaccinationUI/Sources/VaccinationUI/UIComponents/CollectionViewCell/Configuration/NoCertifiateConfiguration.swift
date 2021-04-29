//
//  NoCertifiateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class NoCertifiateConfiguration: BaseCertifiateConfiguration {
    // MARK: - Public Variables 
    
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    
    // MARK: - Init
    
    public init(title: String?, subtitle: String?, image: UIImage?, identifier: String = "\(NoCertificateCollectionViewCell.self)") {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        super.init(backgroundColor: UIConstants.BrandColor.onBackground20, identifer: identifier)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: NoCertifiateConfiguration, rhs: NoCertifiateConfiguration) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}
