//
//  PassDashboard.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import SwiftUI
import VaccinationCommon

public struct PassDashboard: View {
    
    public init() {}
    
    public var body: some View {
        QRGeneratorView()
            .frame(width: 400, height: 400)
    }
}

struct PassDashboard_Previews: PreviewProvider {
    static var previews: some View {
        PassDashboard()
    }
}
