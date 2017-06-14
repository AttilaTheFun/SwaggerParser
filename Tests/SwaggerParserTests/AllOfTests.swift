import XCTest
@testable import SwaggerParser

class AllOfTests: XCTestCase {
    func testAllOfSupport() throws {
        let jsonString = try fixture(named: "test_all_of.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let baseDefinition = swagger.definitions.first(where: { $0.name == "TestAllOfBase" }),
            case .object(let baseSchema) = baseDefinition.structure else
        {
            return XCTFail("TestAllOfBase is not an object schema.")
        }
        
        validate(testAllOfBaseSchema: baseSchema)
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfFoo", withPropertyNames: ["foo"])
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfBar", withPropertyNames: ["bar"])
    }
}
