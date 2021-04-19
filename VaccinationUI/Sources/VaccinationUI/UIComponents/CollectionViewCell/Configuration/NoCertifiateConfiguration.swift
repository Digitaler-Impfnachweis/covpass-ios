//
//  NoCertifiateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class NoCertifiateConfiguration: BaseCertifiateConfiguration {
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    
    public init(title: String?, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        super.init(backgroundColor: UIConstants.BrandColor.onBackground20)
    }
}
