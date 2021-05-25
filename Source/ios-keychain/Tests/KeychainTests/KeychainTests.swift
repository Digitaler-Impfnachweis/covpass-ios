@testable import Keychain
import XCTest

final class KeychainTests: XCTestCase {
    func testBaseQuery() {
        let key = "some_key"
        let dictionary = Keychain.baseQuery(withKey: key, querySecClass: kSecClassCertificate)
        XCTAssertEqual(dictionary[kSecClass] as! CFString, kSecClassCertificate)
        XCTAssertEqual(dictionary[kSecAttrService] as? String, key)
    }

    static var allTests = [
        ("testExample", testBaseQuery)
    ]
}
