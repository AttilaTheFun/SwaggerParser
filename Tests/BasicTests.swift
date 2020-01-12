import XCTest
@testable import OpenAPI
@testable import OpenAPI2

class BasicTests: XCTestCase {
    func testInitialization() throws {
        let jsonString = try fixture(named: "uber.json")
        let swagger: OpenAPI2!
        do {
            swagger = try OpenAPI2(from: jsonString)
        } catch {
            print(error)
            throw error
        }

        XCTAssertEqual(swagger.host?.absoluteString, "api.uber.com")
        testInformation(swagger.information)
    }
}

private func testInformation(_ information: Information) {
    XCTAssertEqual(information.title, "Uber API")
    XCTAssertEqual(information.description, "Move your app forward with the Uber API")
    XCTAssertEqual(information.version, .subversion(1, .subversion(0, .version(0))))
}
