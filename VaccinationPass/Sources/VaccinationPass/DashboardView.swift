//
//  DashboardView.swift
//  
//
//  Created by Daniel on 09.03.2021.
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
