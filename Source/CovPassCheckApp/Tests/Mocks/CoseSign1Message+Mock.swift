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

    private static let token = "HC1:b'6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52O651WG%MPG*ICG5*KMJT7+P66H0*VSZ C1FFF/8X*G-O9 WUQRELS4 CT0Z0:Z23-CY/K5+C$/IU7JB+2D-4Q/S8ALD-IKZ0IZ0%JF6AL**INOV6$0+BN$MVYWV9Y4.$S6ZC0JBV63KD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6FI2 L6GI1:PC27JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*STAK4SI4UU4SI.J9WVHWVH+ZEJFGTRJ3ZC54JS/S7*K .I8OF7:4OHT-3TB6JS1J6:IR/S09T./0LWTKD3323/I0SRJB/S7-SN2H N37J3JFTULJBGJ8X2.36D-I/2DBAJDAJCNB-43 X4VV2 73-E3ND3DAJ-43O*47*KB*KYQTKWT4S8M$MO7CVDBX+VTJM6:NLALKMF6.EZTN-+LQJ583LGAPLE4*HUI.S% N1SB5:P+3GACTEO59XH.M6ZXMAGW78LRB7EHHG P-:Q070J:9M10/A5.4'"}
