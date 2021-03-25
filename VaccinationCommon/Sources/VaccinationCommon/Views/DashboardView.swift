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
    @State private var showActivityIndicator = false

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
    private let base45Encoder = Base45Encoder()

    public init() {}
    
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
            Button(action: encodeJson) {
                Text("Start CBOR encoding")
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

            print("Managed to scan name: \(details[0]) and e-mail address: \(details[1])")
        case .failure(let error):
            print("Scanning failed with error \(error)")
        }
    }

    func encodeJson() {
//        guard let jsonString = convertJson(from: dummyJson) else { return }
//
//        let cborEncodedString = CBOR.encode(jsonString)
//
//        let cborData = Data(cborEncodedString)
        let dummyTestData: [UInt8] = [72, 101, 108, 108, 111, 33, 33]
        let base64CborData = base45Encoder.encode(dummyTestData)
        print("Base45 encoding result is: \(base64CborData)")

        let rawCborData = base45Encoder.decode(base64CborData)
        print("Raw decoded data is: \(rawCborData)")
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
