import XCTest
@testable import SwaggerParser

class AbstractTests: XCTestCase {
    func testAbstract() throws {
        let jsonString = try fixture(named: "test_abstract.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let objectDefinition = swagger.definitions.first(where: { $0.name == "Abstract" }),
            case .object(let objectSchema) = objectDefinition.structure.type else
        {
            return XCTFail("Abstract is not an object schema.")
        }
        
        XCTAssertTrue(objectSchema.abstract)
        
        guard
            let allOfDefinition = swagger.definitions.first(where: { $0.name == "AbstractAllOf" }),
            case .allOf(let allOfSchema) = allOfDefinition.structure.type else
        {
            return XCTFail("AbstractAllOf is not an allOf schema.")
        }
        
        XCTAssertTrue(allOfSchema.abstract)
    }
}
