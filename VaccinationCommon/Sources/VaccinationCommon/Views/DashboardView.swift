//
//  DashboardView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import CodeScanner
import SwiftUI

public struct DashboardView: View {
    @State private var isShowingScanner = false
    @State private var showActivityIndicator = false
    
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            Toggle("Show activity indicator", isOn: $showActivityIndicator)
            viewThatWillChange
        }
    }
    
    var viewThatWillChange: some View {
        VStack {
            Text("Hello, Gabriela")
            Button(action: tap) {
                Text("Tap this Button")
            }
            .font(.title)
            .padding()
            .background(Color.black)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Gabriela Secelean\ngabriela.secelean@ibm.com", completion: self.handleScan)
            }
        }.showLoadingView(when: $showActivityIndicator)
    }
    
    func tap() {
        self.isShowingScanner = true
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            print("Managed to scan name: \(details[0]) and e-mail address \(details[1])")
        case .failure(let error):
            print("Scanning failed with error \(error)")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
