//
//  RevocationInfoRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public struct RevocationInfoRouterMock: RevocationInfoRouterProtocol {
    public init() {}
    public func showPDFExport(with _: RevocationPDFExportDataProtocol) {}
}
