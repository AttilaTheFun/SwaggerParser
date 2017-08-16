import XCTest
@testable import SwaggerParser

private struct VersionTest: Codable {
    let version: Version
}

class VersionTests: XCTestCase {
    func testInitialization() throws {
        let decoder = JSONDecoder()
        let data = "{\"version\":\"1.0.2.3\"}".data(using: .utf8)!
        let versionTest = try decoder.decode(VersionTest.self, from: data)
        let version = versionTest.version
        XCTAssertEqual(version, .subversion(1, .subversion(0, .subversion(2, .version(3)))))
        XCTAssertEqual(version.description, "1.0.2.3")
    }
}

