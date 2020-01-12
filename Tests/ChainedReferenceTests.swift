import XCTest
@testable import OpenAPI2

class ChainedReferenceTests: XCTestCase {
    func testChainedReference() throws {
        let jsonString = try fixture(named: "test_chained_reference.json")
        let swagger: OpenAPI2!
        do {
            swagger = try OpenAPI2(from: jsonString)
        } catch {
            print(error)
            throw error
        }

        // Check Foo Definition

        guard
            let fooDefinition = swagger.definitions["Foo"],
            case .object(let fooObject) = fooDefinition.type else
        {
            return XCTFail("Foo is not an object schema.")
        }

        guard
            let barProperty = fooObject.properties.values.first,
            case .structure(let barStructureSchema) = barProperty.type,
            case .object = barStructureSchema.structure.type else
        {
            return XCTFail("Bar property wasn't resolved correctly")
        }

        XCTAssert(barStructureSchema.name == "Bar")

        // Check Bar Definition

        guard
            let bar = swagger.definitions["Bar"],
            case .object(let barObject) = bar.type else
        {
            return XCTFail("Bar is not an object schema.")
        }

        guard
            let bazProperty = barObject.properties.values.first,
            case .structure(let bazStructureSchema) = bazProperty.type,
            case .object = bazStructureSchema.structure.type else
        {
            return XCTFail("Baz property wasn't resolved correctly")
        }

        XCTAssert(bazStructureSchema.name == "Baz")

        // Check Baz Defintion

        guard
            let baz = swagger.definitions["Baz"],
            case .object(let bazObject) = baz.type else
        {
            return XCTFail("Bar is not an object schema.")
        }

        guard
            let quxProperty = bazObject.properties.values.first,
            case .string = quxProperty.type else
        {
            return XCTFail("Qux property wasn't resolved correctly")
        }
    }
}

