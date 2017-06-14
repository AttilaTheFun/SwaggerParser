import XCTest
@testable import SwaggerParser

class BasicTests: XCTestCase {
    func testInitialization() throws {
        let jsonString = try fixture(named: "uber.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        XCTAssertEqual(swagger.host?.absoluteString, "api.uber.com")
    }
}
