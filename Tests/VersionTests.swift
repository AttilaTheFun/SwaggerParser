import XCTest
@testable import SwaggerParser

private struct VersionTest: Codable {
    let version: Version
}

class VersionTests: XCTestCase {
    func testInitialization() throws {
        let versionTest = try VersionTest(JSONString: "{\"version\":\"1.0.2.3\"}")
        XCTAssertEqual(versionTest.version.components, [1, 0, 2, 3])

        let version = try Version("1.0.2.3")
        XCTAssertEqual(version.components, [1, 0, 2, 3])
        XCTAssertEqual(version.description, "1.0.2.3")
    }
}


