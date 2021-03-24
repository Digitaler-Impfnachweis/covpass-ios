//
//  DashboardView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import CodeScanner
import SwiftCBOR
import SwiftUI

public struct DashboardView: View {
    @State private var isShowingScanner = false

    private let dummyJson: Dictionary<String, String> = [
        "fn": "Mustermann",
        "gn": "Erika",
        "pn": "C01X00T47",
        "bd": "19640812",
        "da": "U07.1!",
        "vp": "1119349007",
        "pr": "COMIRNATY",
        "br": "Pfizer/BioNTech",
        "vs": "2/2",
        "vd": "20210202",
        "ac": "84503",
        "di": "999999900",
        "co": "DE",
        "is": "Ubirch",
        "id": "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S",
        "vf": "20200202",
        "vu": "20230202",
        "ve": "1.0.0",
        "se": "1r8qh67qeqt"
    ]

    public init() {}
    
    public var body: some View {
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
            Button(action: encodeJson) {
                Text("Start CBOR encoding")
            }
        }
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

            print("Managed to scan name: \(details[0]) and e-mail address: \(details[1])")
        case .failure(let error):
            print("Scanning failed with error \(error)")
        }
    }

    func encodeJson() {
        guard let jsonString = convertJson(from: dummyJson) else { return }
        print("JSON String: \(jsonString)")
        let cborEncodedString = CBOR.encode(jsonString)
        print("JSON encoded with CBOR: \(cborEncodedString)")
        let cborData = Data(cborEncodedString)
        let base64CborData = cborData.base64EncodedString()
        print("Base64 encoding result is: \(base64CborData)")
    }

    func convertJson(from stringOject: Dictionary<String, String>) -> String? {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: stringOject, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8)
            return convertedString
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
