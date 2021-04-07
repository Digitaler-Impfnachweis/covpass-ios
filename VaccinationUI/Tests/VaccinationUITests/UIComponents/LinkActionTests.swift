//
//  LinkActionTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class LinkActionTests: XCTestCase {
    struct Result {
        func stringLength(for string: String, keysAndValues: [String: String]) -> Int {
            let delCount = LinkTextView.Constants.delimiter.count * 2
            let sepCount = LinkTextView.Constants.separator.count
            let total = delCount + sepCount
            let valuesCount = keysAndValues.map { $0.value.count }.reduce(0, +)
            return string.count - numberOfKeysAndValues * total - valuesCount
        }

        let numberOfKeysAndValues: Int
        init(number: Int) {
            numberOfKeysAndValues = number
        }
    }

    var samples: [String: Result] = [
        "Hinweis: Speichern Sie den Schlüssel außerhalb ihres Geräts und verwahren Sie ihn sorgfältig. Ohne Schlüssel %@, wenn Sie z.B. Ihr Gerät wechseln.\n\n#Mehr erfahren::faq#": Result(number: 1),
        "Ich bin mit Geltung der #eGA-AGB::agb# einverstanden": Result(number: 1),
        "Ich bin mit Geltung der #eGA-Datenschutzerklärung::datenschutz# einverstanden": Result(number: 1),
        "Sie können Ihre Einwilligung jederzeit mit Wirkung für die Zukunft widerrufen. Weitere Informationen finden Sie in der #eGA-Datenschutzerklärung::datenschutz#.": Result(number: 1),
        "Weitere Informationen zu Ihrem Sicherheitsschlüssel finden Sie in der #eGA-Datenschutzerklärung::datenschutz#.": Result(number: 1),
        "#Was ist der Sicherheits-Schlüssel?::faq#": Result(number: 1),
        "The quick brown fox jumps over the lazy dog": Result(number: 0),
        "Regular text #Blue text::http://fullurl.com/faq#anchor# extra text": Result(number: 1),
        "Regular text #Blue text::http://fullurl.com/faq#anchor#": Result(number: 1),
        "#Blue text::http://fullurl.com/faq#anchor#": Result(number: 1)
    ]
}
