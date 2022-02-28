//
//  Array+ExtendedCBORWebTokenTests.swift
//  
//
//  Created by Thomas Kuleßa on 23.02.22.
//

@testable import CovPassCommon
import XCTest

class ArrayExtendedCBORWebTokenTests: XCTestCase {
    func testPartitionedByOwner_empty() {
        // Given
        let sut: [ExtendedCBORWebToken] = []

        // When
        let partitions = sut.partitionedByOwner

        // Then
        XCTAssertTrue(partitions.isEmpty)
    }

    func testPartitionedByOwner() {
        // Given
        var token1Owner1 = CBORWebToken.mockVaccinationCertificate
        var token2Owner1 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner2 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner3 = CBORWebToken.mockVaccinationCertificate
        token1Owner1.hcert.dgc = .mock(name: .mustermann())
        token2Owner1.hcert.dgc = .mock(name: .mustermann())
        tokenOwner2.hcert.dgc = .mock(name: .yildirim())
        tokenOwner3.hcert.dgc = .mock(name: .mustermann(), dob: Date())
        let sut = [
            token1Owner1.extended(),
            token2Owner1.extended(),
            tokenOwner2.extended(),
            tokenOwner3.extended()
        ]

        // When
        let partitions = sut.partitionedByOwner

        // Then
        XCTAssertEqual(partitions.count, 3)
        if partitions.count > 2 {
            XCTAssertTrue(
                (partitions[0].count == 2 && partitions[1].count == 1 && partitions[2].count == 1) ||
                (partitions[0].count == 1 && partitions[1].count == 2 && partitions[2].count == 1) ||
                (partitions[0].count == 1 && partitions[1].count == 1 && partitions[2].count == 2) 
            )
        }
    }
}

private extension DigitalGreenCertificate {
    static func mock(name: Name = .mustermann(), dob: Date? = nil) -> DigitalGreenCertificate {
        .init(nam: name, dob: dob, dobString: nil, v: nil, t: nil, r: nil, ver: "1.0")
    }
}

private extension Name {
    static func mustermann() -> Name {
        .init(gn: nil, fn: nil, gnt: nil, fnt: "MUSTERMANN")
    }
    static func yildirim() -> Name {
        .init(gn: nil, fn: nil, gnt: nil, fnt: "YILDIRIM")
    }
}
