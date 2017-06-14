import XCTest
@testable import SwaggerParser

class ExampleTests: XCTestCase {
    func testExamples() throws {
        let jsonString = try fixture(named: "test_examples.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let definition = swagger.definitions.first(where: { $0.name == "Example" }),
            case .object(let schema) = definition.structure else
        {
            return XCTFail("Example is not an object schema.")
        }
        
        guard
            let aStringProperty = schema.properties["a-string"],
            case .string(let aStringMetadata, let aStringOptionalFormat) = aStringProperty else
        {
            return XCTFail("Example has no string property 'a-string'.")
        }
        
        guard
            let anOptionalStringFormat = aStringOptionalFormat,
            case .other(let aStringFormatValue) = anOptionalStringFormat,
            aStringFormatValue == "custom" else
        {
            return XCTFail("Example's 'a-string' does not have `custom` format type.")
        }
        
        XCTAssertEqual(aStringMetadata.example as? String, "Example String")
        
        guard
            let anIntegerProperty = schema.properties["an-integer"],
            case .integer(let anIntegerMetadata, _) = anIntegerProperty else
        {
            return XCTFail("Example has no string property 'an-integer'.")
        }
        
        XCTAssertEqual(anIntegerMetadata.example as? Int64, 987)
        
        guard
            let exampleIDPath = swagger.paths["/test-examples/{exampleId}"],
            let exampleIDOperation = exampleIDPath.operations[.post] else
        {
            return XCTFail("POST /test-examples/{exampleId} not found.")
        }
        
        XCTAssertEqual(exampleIDOperation.parameters.count, 1)
        
        guard
            let exampleIDOperationParameter = exampleIDOperation.parameters.first,
            case .a(let exampleIDParameter) = exampleIDOperationParameter else
        {
            return XCTFail("Example ID parameter should not be a structure.")
        }
        
        guard case .other(let exampleIDFixed, _) = exampleIDParameter else {
            XCTFail("Example ID parameter is not .other."); return
        }
        
        XCTAssertEqual(exampleIDFixed.example as? String, "E_123")
    }
}
