//
//  String+Filename.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import Foundation
import XCTest

@testable import CovPassCommon

class StringFilenameTests: XCTestCase {
    func testFilenameSanitizer() {
        XCTAssertEqual("file.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual("file/.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual("file\\.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual("file^.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual(".file.txt".sanitizedFileName, ".file.txt")
        XCTAssertEqual("~/file.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual("/file.txt".sanitizedFileName, "file.txt")
        XCTAssertEqual("_-file.txt".sanitizedFileName, "_-file.txt")
        XCTAssertEqual("!@#%$^&*=~\"\\<>+{}()[]/:;'`?,".sanitizedFileName, "")
        XCTAssertEqual("aouäöüÄÖÜß.pdf".sanitizedFileName, "aouäöüÄÖÜß.pdf")
    }

    func testPathTraversing() {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let reference = tempDir.appendingPathComponent("file.txt".sanitizedFileName)
        let referenceDir = reference.standardizedFileURL.deletingLastPathComponent()
        XCTAssertEqual(tempDir.absoluteString, referenceDir.absoluteString)

        // path traversal if not escaped
        let reference2 = tempDir.appendingPathComponent("../file.txt")
        let referenceDir2 = reference2.standardizedFileURL.deletingLastPathComponent()
        XCTAssertNotEqual(tempDir.absoluteString, referenceDir2.absoluteString)

        // check if all escaped file names stay in `tempDir`
        BLNS.testStrings.forEach { string in
            if string.sanitizedFileName.isEmpty { return }
            let checkFile = tempDir.appendingPathComponent(string.sanitizedFileName)
            let checkDir = checkFile.standardizedFileURL.deletingLastPathComponent()

            XCTAssertEqual(referenceDir.absoluteString, checkDir.absoluteString)
        }
    }
}
