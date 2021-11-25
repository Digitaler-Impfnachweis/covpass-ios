//
//  UIFont+CustomFonts.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension Font {
    static func sansRegular(size: CGFloat, relativeTo: TextStyle = .body) -> Font {
        .custom("OpenSans-Regular", size: size, relativeTo: relativeTo)
    }
    
    static func sansBold(size: CGFloat, relativeTo: TextStyle = .body) -> Font {
        .custom("OpenSans-Bold", size: size, relativeTo: relativeTo)
    }
    
    static func sansSemiBold(size: CGFloat, relativeTo: TextStyle = .body) -> Font {
        .custom("OpenSans-SemiBold", size: size, relativeTo: relativeTo)
    }
}
