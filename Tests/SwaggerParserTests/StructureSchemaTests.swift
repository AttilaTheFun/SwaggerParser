import XCTest
@testable import SwaggerParser

class StructureSchemaTests: XCTestCase {
    func testPointerMetadata() throws {
        let jsonString = try fixture(named: "test_pointer_metadata.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let fooDefinition = swagger.definitions.first(where: { $0.name == "Foo" }),
            case .object(let foo) = fooDefinition.structure.type else
        {
            return XCTFail("Foo is not an object schema.")
        }
        
        guard
            let barProperty = foo.properties["bar"],
            case .structure(let barReference) = barProperty.type,
            case .object(let bar) = barReference.structure.type else
        {
            return XCTFail("Bar property is not a reference to an object schema.")
        }
        
        guard
            let bazProperty = bar.properties["baz"],
            case .string = bazProperty.type else
        {
            return XCTFail("Baz property is not a string.")
        }
        
        XCTAssertEqual(barProperty.metadata.description, "A nullable reference to Bar.")
        XCTAssertTrue(barProperty.metadata.nullable)
    }
}

