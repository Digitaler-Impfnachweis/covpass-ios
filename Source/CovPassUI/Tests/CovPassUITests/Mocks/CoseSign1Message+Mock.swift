//
//  CoseSign1Message+Mock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CoseSign1Message {
    static func mock() -> Self {
        let decodedCertificate = try! Base45Coder.decode(token.stripPrefix())
        let data = Compression.decompress(Data(decodedCertificate))
        let message = try! CoseSign1Message(decompressedPayload: data!)
        return message
    }

    private static let token = "HC1:6BFOXN%TSMAHN-HISCCPV4DU30PMXK/R89PPNDC2LE%$CAJ9AIVG8QB/I:VPI7ONO4*J8/Y4IGF5JNBPINXUQXJ $U H9IRIBPI$RU2G0BI6QJAWVH/UI2YU-H6/V7Y0W*VBCZ79XQLWJM27F75R540T9S/FP1JXGGXHGTGK%12N:IN1MPK9PYL+Q6JWE 0R746QW6T3R/Q6ZC6:66746+O615F631$02VB1%96$01W.M.NEQ7VU+U-RUV*6SR6H 1PK9//0OK5UX4795Y%KBAD5II+:LQ12J%44$2%35Y.IE.KD+2H0D3ZCU7JI$2K3JQH5-Y3$PA$HSCHBI I799.Q5*PP:+P*.1D9R+Q0$*OWGOKEQEC5L64HX6IAS3DS2980IQODPUHLO$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L6G%5TW5A 6YO67N6N7E931U9N%QLXVT*VHHP7VRDSIEAP5M9N0SB9BODZV0JEY9KQ7KEWP.T2E:7*CAC:C5Z873UF C+9OB.5TDU1PT %F6NATW6513TMG.:A+5AOPG"
}
