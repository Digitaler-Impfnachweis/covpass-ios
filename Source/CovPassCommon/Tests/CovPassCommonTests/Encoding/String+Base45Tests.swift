//
//  String+Base45Tests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class StringBase45Tests: XCTestCase {
    func testDecodedBase45_reissue_certificate() {
        // Given
        let expectation = XCTestExpectation()
        let sut = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEMWK4MI6UOS03CR83KLBKAVN74.CL91/8K6%KEG3983NS9SVBHABVCNN95SWMPHQUHQN%A400H%UBT16Y51Y9AT1:+P6YBKD0:XB7NGJQOIS7I$H%T5+XO8YJMVHBZJF 9NSG:PICIG%*47%S%*48YIZ73423ZQT-EJDG3XW44$22CLY.IE.KD+2H0D3ZCU7JI$2K3JQH5-Y3$PA$HSCHBI I7995R5ZFQETU 9R*PP:+P*.1D9RYO05QD/8D3FC:XIBEIVG395EP1E+WEDJL8FF3DE0OA0D9E2LBHHNHL$EQ+-CVYCMBB:AV5AL5:4A93MOJLWT.C3FDA.-B97U: KMZNKASADIMKN2GFLF9$HF.3O.X21FDLW4L4OVIOE1M24OR:FTNP8EFVMP9/HWKP/HLIJL8JF8JF172OTTHO9YW2E6LS7WGYNDDSHRSFXT*LMK8P*G8QWD8%P%5GPPMEVMTHDBESW2L.TN8BBBDR9+JLDR/1JGIF8BS0IKT8LB1T7WLA:FI%JI50H:EK1"

        // When
        sut.decodedBase45
            .done { _ in
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Must not fail with error: \(error)")
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testDecodedBase45_failure() {
        // Given
        let expectation = XCTestExpectation()
        let sut = "Not a Base45 string."

        // When
        sut.decodedBase45
            .done { _ in
                XCTFail("Must fail with error.")
            }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testDecodedBase45_success() {
        // Given
        let expectedValues: [UInt8] = [34, 98, 123, 201]
        let sut = "RF49TF"
        let expectation = XCTestExpectation()

        // When
        sut.decodedBase45
            .done { data in
                let values = [UInt8](data)
                XCTAssertEqual(values, expectedValues)
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Must not fail with error: \(error)")
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}
