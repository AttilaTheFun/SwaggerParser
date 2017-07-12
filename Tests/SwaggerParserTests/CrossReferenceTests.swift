import XCTest
@testable import SwaggerParser

class CrossReferenceTests: XCTestCase {
    func testCrossReference() throws {
        let jsonString = try fixture(named: "test_cross_reference.json")
        let swagger = try Swagger(JSONString: jsonString)

        guard
            let definition = swagger.definitions.first(where: { $0.name == "Foo" }),
            case .structure = definition.structure.type else
        {
            return XCTFail("Foo is not a structure schema.")
        }
    }
}
