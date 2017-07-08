import XCTest
@testable import SwaggerParser

class CrossReferenceTests: XCTestCase {
    func testCrossReference() throws {
        let jsonString = try fixture(named: "test_cross_reference.json")
        let swagger = try Swagger(JSONString: jsonString)

        guard
            let definition = swagger.definitions.first(where: { $0.name == "Foo" }),
            case .object = definition.structure else
        {
            return XCTFail("Foo is not an object schema.")
        }
        guard
            case let .object(objectSchema) = definition.structure,
            let property = objectSchema.properties.values.first,
            case let .structure(_, structure) = property,
            structure.name == "Bar" else
        {
            return XCTFail("Foo does not contain reference to Bar.")
        }
        guard
            case let .object(objectSchema2) = structure.structure,
            let property2 = objectSchema2.properties.values.first,
            case let .structure(_, structure2) = property2,
            structure2.name == "Foo" else
        {
            return XCTFail("Bar does not contain reference to Foo.")
        }
    }
}
