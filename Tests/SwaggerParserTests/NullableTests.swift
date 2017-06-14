import XCTest
@testable import SwaggerParser

class NullableTests: XCTestCase {
    func testNullable() throws {
        let jsonString = try fixture(named: "test_nullable.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let definition = swagger.definitions.first(where: { $0.name == "Test" }),
            case .object(let object) = definition.structure else
        {
            return XCTFail("Test is not an object schema.")
        }
        
        guard
            let foo = object.properties["foo"],
            case .string(let fooMetadata, _) = foo else
        {
            return XCTFail("Test has no string property foo.")
        }
        
        XCTAssertTrue(fooMetadata.nullable)
        
        guard
            let bar = object.properties["bar"],
            case .string(let barMetadata, _) = bar else
        {
            return XCTFail("Test has no string property bar.")
        }
        
        XCTAssertFalse(barMetadata.nullable)
        
        guard
            let qux = object.properties["qux"],
            case .string(let quxMetadata, _) = qux else
        {
            return XCTFail("Test has no string property qux.")
        }
        
        XCTAssertFalse(quxMetadata.nullable)
    }
}
