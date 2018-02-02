import XCTest
@testable import OpenAPI2

class AbstractTests: XCTestCase {
    func testAbstract() throws {
        let jsonString = try fixture(named: "test_abstract.json")
        let swagger: OpenAPI2!
        do {
            swagger = try OpenAPI2(from: jsonString)
        } catch {
            print(error)
            throw error
        }

        guard
            let objectDefinition = swagger.definitions["Abstract"],
            case .object(let objectSchema) = objectDefinition.type else
        {
            return XCTFail("Abstract is not an object schema.")
        }

        XCTAssertTrue(objectSchema.metadata.abstract)

        guard
            let allOfDefinition = swagger.definitions["AbstractAllOf"],
            case .allOf(let allOfSchema) = allOfDefinition.type else
        {
            return XCTFail("AbstractAllOf is not an allOf schema.")
        }

        XCTAssertTrue(allOfSchema.abstract)
    }
}
