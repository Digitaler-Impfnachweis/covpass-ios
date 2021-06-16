import AVFoundation
@testable import Scanner
import XCTest

class ScannerTests: XCTestCase {
    // MARK: - Test variables

    var scannerDelegate: DefaultScannerDelegate?

    // MARK: - Setup&Teardown

    override func setUp() {
        super.setUp()
        scannerDelegate = DefaultScannerDelegate()
    }

    override func tearDown() {
        scannerDelegate = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testQRScanner() {
        let qrScanner = Scanner.viewController(codeTypes: [.dataMatrix], delegate: scannerDelegate)
        XCTAssertNotNil(qrScanner)
        XCTAssertTrue(scannerDelegate === qrScanner.coordindator?.delegate)
    }
}
