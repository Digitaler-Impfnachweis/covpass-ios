//
//  SecKey+Mock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Security

extension SecKey {
    static func mock() throws -> SecKey {
        let keyPEM = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIxHvrv8jQx9OEzTZbsx1prQVQn/3
        ex0gMYf6GyaNBW0QKLMjrSDeN6HwSPM0QzhvhmyQUixl6l88A7Zpu5OWSw==
        -----END PUBLIC KEY-----
        """
        let key = try keyPEM.secKey()
        return key
    }
}
