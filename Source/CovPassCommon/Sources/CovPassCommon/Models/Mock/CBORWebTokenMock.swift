//
//  CBORWebTokenMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension CBORWebToken {
    static var mockVaccinationCertificate: CBORWebToken {
        CBORWebToken(
            iss: "DE",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Doe",
                        fn: "John",
                        gnt: "DOE",
                        fnt: "JOHN"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    v: [
                        Vaccination(
                            tg: "840539006",
                            vp: "1119349007",
                            mp: "EU/1/20/1528",
                            ma: "ORG-100001699",
                            dn: 2,
                            sd: 2,
                            dt: DateUtils.isoDateFormatter.date(from: "2021-01-01")!,
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IZ12345A/4O2O25ZXNQED2R69JTL6FQ#P"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }

    static var mockVaccinationCertificate3Of2: CBORWebToken {
        CBORWebToken(
            iss: "DE",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Doe",
                        fn: "John",
                        gnt: "DOE",
                        fnt: "JOHN"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    v: [
                        Vaccination(
                            tg: "840539006",
                            vp: "1119349007",
                            mp: "EU/1/20/1528",
                            ma: "ORG-100001699",
                            dn: 3,
                            sd: 2,
                            dt: DateUtils.isoDateFormatter.date(from: "2021-01-01")!,
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IZ12345A/4O2O25ZXNQED2R69JTL6FQ#P"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }

    static var mockVaccinationCertificateWithOtherName: CBORWebToken {
        CBORWebToken(
            iss: "DE",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Katami",
                        fn: "Ella",
                        gnt: "KATAMI",
                        fnt: "ELLA"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    v: [
                        Vaccination(
                            tg: "840539006",
                            vp: "1119349007",
                            mp: "EU/1/20/1528",
                            ma: "ORG-100001699",
                            dn: 3,
                            sd: 2,
                            dt: DateUtils.isoDateFormatter.date(from: "2021-01-01")!,
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IZ12345A/4O2O25ZXNQED2R69JTL6FQ#P"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }

    static var mockTestCertificate: CBORWebToken {
        CBORWebToken(
            iss: "DE",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Doe",
                        fn: "John",
                        gnt: "DOE",
                        fnt: "JOHN"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    t: [
                        Test(
                            tg: "840539006",
                            tt: "LP6464-4",
                            nm: "SARS-CoV-2 PCR Test",
                            ma: "1360",
                            sc: Date(),
                            tr: "260373001",
                            tc: "Test Center",
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IBMT102/18Q12HTUJ45NO7ZTR2RGAS#C"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }

    static var mockRecoveryCertificate: CBORWebToken {
        CBORWebToken(
            iss: "DE",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Doe",
                        fn: "John",
                        gnt: "DOE",
                        fnt: "JOHN"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    r: [
                        Recovery(
                            tg: "840539006",
                            fr: DateUtils.isoDateFormatter.date(from: "2022-02-01")!,
                            df: DateUtils.isoDateFormatter.date(from: "2022-03-01")!,
                            du: DateUtils.isoDateFormatter.date(from: "2022-5-01")!,
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IBMT102/5Z0SOLAZ3PXOZYEA75E2E#D"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }
}

public struct KeyPair {
    var publicKey: SecKey
    var privateKey: SecKey

    public init(publicKey: SecKey, privateKey: SecKey) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    public static var `default`: KeyPair = {
        var publicKey: SecKey?
        var privateKey: SecKey?
        _ = SecKeyGeneratePair([
            kSecAttrApplicationTag as String: UUID().uuidString,
            kSecAttrLabel as String: UUID().uuidString,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ] as NSDictionary, &publicKey, &privateKey)
        return KeyPair(publicKey: publicKey!, privateKey: privateKey!)
    }()
}

public class TrustCertificateMock: TrustCertificate {
    public init() {
        super.init(certificateType: "", country: "DE", kid: "", rawData: "", signature: "", thumbprint: "", timestamp: "")
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override public func loadPublicKey() throws -> SecKey {
        KeyPair.default.publicKey
    }
}

public extension TrustList {
    static var mock: TrustList {
        TrustList(certificates: [
            TrustCertificateMock()
        ])
    }
}

public extension CBORWebToken {
    func generateQRCodeData(with keyPair: KeyPair = .default) throws -> String {
        let json = try JSONEncoder().encode(self)
        var cose = try CoseSign1Message(jsonData: json)
        cose.signature = [UInt8](try HCert.createSignature(message: cose, privateKey: keyPair.privateKey))
        let signedData = try cose.toCBOR()
        guard let compressedData = signedData.compress(withAlgorithm: .zlib) else { throw ApplicationError.unknownError }
        return "HC1:" + Base45Coder.encode([UInt8](compressedData))
    }
}
