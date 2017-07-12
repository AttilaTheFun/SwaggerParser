import XCTest
@testable import SwaggerParser

class CrossReferenceTests: XCTestCase {
    func testCrossReference() throws {
        let jsonString = try fixture(named: "test_cross_reference.json")
        let swagger = try Swagger(JSONString: jsonString)

        // Check Foo definition:

        guard
            let fooDefinition = swagger.definitions.first(where: { $0.name == "Foo" }),
            case .object(let fooObject) = fooDefinition.structure.type else
        {
            return XCTFail("Foo is not a structure schema.")
        }

        guard
            let barProperty = fooObject.properties.values.first,
            case .structure(let barSchema) = barProperty.type,
            barSchema.name == "Bar" else
        {
            return XCTFail("Foo does not contain reference to Bar.")
        }

        // Check Bar definition:

        guard
            let barDefinition = swagger.definitions.first(where: { $0.name == "Bar" }),
            case .object(let barObject) = barDefinition.structure.type else
        {
            return XCTFail("Bar is not an object schema.")
        }

        guard
            let fooProperty = barObject.properties.values.first,
            case .structure(let fooSchema) = fooProperty.type,
            fooSchema.name == "Foo" else
        {
            return XCTFail("Bar does not contain reference to Foo.")
        }
    }
}
