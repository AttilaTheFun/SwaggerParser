import XCTest
@testable import SwaggerParser

class SwaggerParserTests: XCTestCase {
    var testFixtureFolder: URL!
    
    override func setUp() {
        testFixtureFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
    }
    
    func testInitialization() {
        let url = testFixtureFolder.appendingPathComponent("uber.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        XCTAssertEqual(swagger.host?.absoluteString, "api.uber.com")
    }
    
    func testAllOfSupport() {
        let url = testFixtureFolder.appendingPathComponent("test_all_of.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        guard
            let baseDefinition = swagger.definitions.first(where: {$0.name == "TestAllOfBase"}),
            case .object(let baseSchema) = baseDefinition.structure else {
                XCTFail("TestAllOfBase is not an object schema."); return
        }
        
        SwaggerParserTests.validate(testAllOfBaseSchema: baseSchema)
        swagger.definitions.validate(testAllOfChild: "TestAllOfFoo", withPropertyNames: ["foo"])
        swagger.definitions.validate(testAllOfChild: "TestAllOfBar", withPropertyNames: ["bar"])
    }
}

/// MARK: Helper Functions

fileprivate extension SwaggerParserTests {
    /// Gets the base schema and child schema from a definition that defines an
    /// `allOf` with one $ref (the base class) and one object schema.
    class func getBaseAndChildSchemas(withDefinition definition: Structure<Schema>) -> (base: ObjectSchema?, child: ObjectSchema?) {
        var base: ObjectSchema?
        var child: ObjectSchema?
        
        if case .allOf(let schema) = definition.structure {
            XCTAssertEqual(schema.schemas.count, 2)
            
            schema.schemas.forEach {
                switch $0 {
                case .object(let childSchema):
                    child = childSchema
                case .structure(let structure):
                    guard case .object(let baseSchema) = structure.structure else {fatalError()}
                    base = baseSchema
                default: fatalError()
                }
            }
        }
        return (base: base, child: child)
    }
}

/// MARK: Validation functions

fileprivate extension SwaggerParserTests {
    class func validate(testAllOfBaseSchema schema: ObjectSchema) {
        validate(thatSchema: schema, named: "TestAllOfBase", hasRequiredProperties: ["base", "test_type"])
    }

    class func validate(thatSchema schema: ObjectSchema, named name: String, hasRequiredProperties properties: [String]) {
        XCTAssertEqual(schema.properties.count, properties.count)
        XCTAssertEqual(schema.required, properties)
        
        properties.forEach { property in
            XCTAssertNotNil(schema.properties.first(where: {$0.key == property}))
        }
    }
    
    class func validate(thatParameter parameter: Parameter, named parameterName: String, isAnObjectNamed objectName: String, withPropertyName objectPropertyName: String) {
        guard case .body(_, let schema) = parameter else {
            XCTFail("\(parameterName) is not a .body."); return
        }
        guard case .structure(let structure) = schema else {
            XCTFail("\(parameterName)'s schema is not a .structure."); return
        }
        XCTAssertEqual(structure.name, objectName)
        
        guard case .object(let object) = structure.structure else {
            XCTFail("\(parameterName)'s schema's structure is not an .object."); return
        }
        
        XCTAssertTrue(object.properties.contains(where: {$0.key == objectPropertyName}))
    }
    
    class func validate(thatChildSchema childSchema: Schema, named childName: String, withProperties childProperties: [String], hasParentNamed parentName: String, withProperties parentProperties: [String]) {
        guard case .allOf(let childAllOf) = childSchema else {
            XCTFail("\(childName) is not an allOf."); return
        }
        XCTAssertEqual(childAllOf.schemas.count, 2)
        
        guard
            let childsParent = childAllOf.schemas.first,
            case .structure(let childsParentStructure) = childsParent,
            childsParentStructure.name == parentName,
            case .object(let childsParentSchema) = childsParentStructure.structure else {
                XCTFail("\(childName)'s parent is not a Structure<Schema.object>"); return
        }
        SwaggerParserTests.validate(thatSchema: childsParentSchema, named: parentName, hasRequiredProperties: parentProperties)
        
        guard
            let child = childAllOf.schemas.last,
            case .object(let childSchema) = child else {
                XCTFail("child is not a Structure<Schema.object>"); return
        }
        SwaggerParserTests.validate(thatSchema: childSchema, named: childName, hasRequiredProperties: childProperties)
    }
}

/// MARK: Swagger Definitions Extension

fileprivate extension Array where Element == Structure<Schema> {
    func validate(testAllOfChild name: String, withPropertyNames propertyNames: [String]) {
        let testAllOfChild = self.first(where: {$0.name == name})!
        let childSchemas = SwaggerParserTests.getBaseAndChildSchemas(withDefinition: testAllOfChild)
        
        SwaggerParserTests.validate(testAllOfBaseSchema: childSchemas.base!)
        SwaggerParserTests.validate(thatSchema: childSchemas.child!, named: name, hasRequiredProperties: propertyNames)
    }
}
