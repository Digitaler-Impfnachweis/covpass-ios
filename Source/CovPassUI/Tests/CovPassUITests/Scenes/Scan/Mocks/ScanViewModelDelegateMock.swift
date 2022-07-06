//
//  ScanViewModelDelegateMock.swift
//  
//
//  Created by Thomas Kuleßa on 05.07.22.
//

@testable import CovPassUI
import XCTest

final class ScanViewModelDelegateMock: ScanViewModelDelegate {
    let viewModelDidChangeExpectation = XCTestExpectation(description: "viewModelDidChangeExpectation")
    let selectFilesExpectation = XCTestExpectation(description: "selectFilesExpectation")
    let selectImagesExpectation = XCTestExpectation(description: "selectImagesExpectation")

    func selectFiles() {
        selectFilesExpectation.fulfill()
    }

    func selectImages() {
        selectImagesExpectation.fulfill()
    }

    func viewModelDidChange() {
        viewModelDidChangeExpectation.fulfill()
    }
}
