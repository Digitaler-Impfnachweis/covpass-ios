//
//  QRCodeImportResult.swift
//
//  © Copyright IBM Deutschland GmbH 2022
//  SPDX-License-Identifier: Apache-2.0
//

public enum QRCodeImportResult {
    case pickerImport
    case scanResult(ScanResult)
}
