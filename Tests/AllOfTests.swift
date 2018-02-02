import XCTest
@testable import OpenAPI2

class AllOfTests: XCTestCase {
    func testAllOfSupport() throws {
        let jsonString = try fixture(named: "test_all_of.json")
        let swagger: OpenAPI2!
        do {
            swagger = try OpenAPI2(from: jsonString)
        } catch {
            print(error)
            throw error
        }
        
        guard
            let baseDefinition = swagger.definitions["TestAllOfBase"],
            case .object(let baseSchema) = baseDefinition.type else
        {
            return XCTFail("TestAllOfBase is not an object schema.")
        }

        validate(testAllOfBaseSchema: baseSchema)
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfFoo", withPropertyNames: ["foo"])
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfBar", withPropertyNames: ["bar"])

        guard
            let fooDefinition = swagger.definitions["TestAllOfFoo"],
            case .allOf = fooDefinition.type else
        {
            return XCTFail("TestAllOfFoo is not an object schema.")
        }

        XCTAssertEqual(fooDefinition.metadata.description, "This is an AllOf description.")
    }
}
