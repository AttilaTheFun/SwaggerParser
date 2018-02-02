import XCTest
@testable import OpenAPI2

class NullableTests: XCTestCase {
    func testNullable() throws {
        let jsonString = try fixture(named: "test_nullable.json")
        let swagger: OpenAPI2!
        do {
            swagger = try OpenAPI2(from: jsonString)
        } catch {
            print(error)
            throw error
        }

        guard
            let definition = swagger.definitions["Test"],
            case .object(let object) = definition.type else
        {
            return XCTFail("Test is not an object schema.")
        }

        guard let foo = object.properties["foo"] else {
            return XCTFail("Test has no string property foo.")
        }

        XCTAssertTrue(foo.metadata.nullable)

        guard let bar = object.properties["bar"] else {
            return XCTFail("Test has no string property bar.")
        }

        XCTAssertFalse(bar.metadata.nullable)

        guard let qux = object.properties["qux"] else {
            return XCTFail("Test has no string property qux.")
        }

        XCTAssertFalse(qux.metadata.nullable)
    }
}

