//
//  DashboardView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import SwiftUI

public struct DashboardView: View {
    
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            Text("Hello, Gabrilea")
            Button(action: tap) {
                Text("Tap this Buttom")
            }
        }
    }
    
    func tap() {
        
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
