import XCTest
@testable import SwaggerParser

class SwaggerParserTests: XCTestCase {
    var testFixtureFolder: URL!
    
    override func setUp() {
        testFixtureFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
    }
    
    func testInitialization() throws {
        let jsonString = try self.fixture(named: "uber.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        XCTAssertEqual(swagger.host?.absoluteString, "api.uber.com")
    }
    
    func testAllOfSupport() throws {
        let jsonString = try fixture(named: "test_all_of.json")
        let swagger = try Swagger(JSONString: jsonString)
        
        guard
            let baseDefinition = swagger.definitions.first(where: { $0.name == "TestAllOfBase" }),
            case .object(let baseSchema) = baseDefinition.structure else
        {
            return XCTFail("TestAllOfBase is not an object schema.")
        }
        
        validate(testAllOfBaseSchema: baseSchema)
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfFoo", withPropertyNames: ["foo"])
        try validate(that: swagger.definitions, containsTestAllOfChild: "TestAllOfBar", withPropertyNames: ["bar"])
    }
    
    func testSeparated() {
        let url = testFixtureFolder.appendingPathComponent("Separated").appendingPathComponent("test.json")
        let swagger = try! Swagger(URL: url)
        XCTAssertEqual(swagger.host?.absoluteString, "api.test.com")
        
        XCTAssertEqual(swagger.definitions.count, 5)
        
        let parentName = "parent"
        let parentPropertyNames = ["type"]
        
        guard
            let parentDefinition = swagger.definitions.first(where: { $0.name == parentName }),
            case .object(let parent) = parentDefinition.structure else
        {
            return XCTFail("child is not an object.")
        }
        
        validate(that: parent, named: parentName, hasRequiredProperties: parentPropertyNames)
        
        let childName = "child"
        let childPropertyNames = ["reference"]
        
        guard let childDefinition = swagger.definitions.first(where: { $0.name == childName }) else {
            return XCTFail("\(childName) definition not found.")
        }
        
        let childSchema = childDefinition.structure
        
        validate(
            that: childSchema,
            named: childName,
            withProperties: childPropertyNames,
            hasParentNamed: parentName,
            withProperties: parentPropertyNames)
        
        guard
            let either = swagger.paths["/test"]?.operations[.get]?.responses[200],
            case .a(let response) = either else
        {
            return XCTFail("response not found for GET /test 200.")
        }
        
        guard
            let responseSchema = response.schema,
            case .structure(let responseSchemaStructure) = responseSchema else
        {
            return XCTFail("response schema is not a structure.")
        }
        
        XCTAssertEqual(responseSchemaStructure.name, childName)
        
        let responseChildSchema = responseSchemaStructure.structure
        
        validate(
            that: responseChildSchema,
            named: childName,
            withProperties: childPropertyNames,
            hasParentNamed: parentName,
            withProperties: parentPropertyNames)
        
        guard
            let referenceDefinition = swagger.definitions.first(where: { $0.name == "definitions-reference" }),
            case .object(let definitionRef) = referenceDefinition.structure else
        {
            return XCTFail("`definitions-reference` is not an object.")
        }
        
        XCTAssertNotNil(definitionRef.properties.first(where: { $0.key == "bar" })?.value)
        
        guard case .allOf(let allOf) = responseChildSchema else {
            return XCTFail("Response schema is not an .allOf")
        }
        
        XCTAssertEqual(allOf.subschemas.count, 2)
        
        guard
            let childAllOfSchema = allOf.subschemas.last,
            case .object(let child) = childAllOfSchema else
        {
            return XCTFail("Response schema's .allOf's last item is not an .object")
        }
        
        guard let referenceProperty = child.properties.first(where: { $0.key == "reference" })?.value else {
            return XCTFail("Response schema's .allOf's last item does not have a 'reference' property.")
        }
        
        guard
            case .structure(let referenceStructure) = referenceProperty,
            referenceStructure.name == "reference",
            case .object(let reference) = referenceStructure.structure else
        {
            return XCTFail("Response schema's .allOf's last item's 'reference' property is not a Structure<Schema.object>.")
        }
        
        guard
            let arrayProperty = reference.properties.first(where: { $0.key == "array-items" })?.value,
            case .array(let arraySchema) = arrayProperty,
            case .one(let arrayItemSchema) = arraySchema.items else
        {
            return XCTFail("Array property not found on reference.")
        }
        
        guard
            case .structure(let arrayStructure) = arrayItemSchema,
            arrayStructure.name == "array-item",
            case .object(let arrayItemObjectSchema) = arrayStructure.structure else
        {
            return XCTFail("`array-items` poprety does not contain an object reference.")
        }
        
        XCTAssertNotNil(arrayItemObjectSchema.properties.first(where: { $0.key == "foo" })?.value)
    }
}

/// MARK: Helper Functions

fileprivate extension SwaggerParserTests {
    func fixture(named fileName: String) throws -> String {
        let url = testFixtureFolder.appendingPathComponent(fileName)
        return try String.init(contentsOf: url, encoding: .utf8)
    }
}
    
fileprivate enum GetBaseAndChildSchemasError: Error {
    case missingBase
    case missingChild
    case badSubschemaType(Schema)
    case notAllOf
    case incorrectSubschemaCount
}

/// Gets the base schema and child schema from a definition that defines an
/// `allOf` with one $ref (the base class) and one object schema.
fileprivate func getBaseAndChildSchemas(withDefinition definition: Structure<Schema>) throws -> (base: ObjectSchema, child: ObjectSchema) {
    guard case .allOf(let allOfSchema) = definition.structure else {
        throw GetBaseAndChildSchemasError.notAllOf
    }
    
    if allOfSchema.subschemas.count != 2 {
        throw GetBaseAndChildSchemasError.incorrectSubschemaCount
    }
    
    var base: ObjectSchema!
    var child: ObjectSchema!
    
    try allOfSchema.subschemas.forEach { subschema in
        switch subschema {
        case .object(let childSchema):
            child = childSchema
        case .structure(let structure):
            guard case .object(let baseSchema) = structure.structure else {
                throw GetBaseAndChildSchemasError.badSubschemaType(subschema)
            }
            
            base = baseSchema
        default:
            throw GetBaseAndChildSchemasError.badSubschemaType(subschema)
        }
    }
    
    if base == nil {
        throw GetBaseAndChildSchemasError.missingBase
    }
    
    if child == nil {
        throw GetBaseAndChildSchemasError.missingChild
    }
    
    return (base: base, child: child)
}

/// MARK: Validation functions

fileprivate func validate(testAllOfBaseSchema schema: ObjectSchema) {
    validate(that: schema, named: "TestAllOfBase", hasRequiredProperties: ["base", "test_type"])
}

fileprivate func validate(that schema: ObjectSchema, named name: String, hasRequiredProperties properties: [String]) {
    XCTAssertEqual(schema.properties.count, properties.count)
    XCTAssertEqual(schema.required, properties)
    
    let keys = Set(schema.properties.keys)
    properties.forEach { XCTAssertTrue(keys.contains($0)) }
}

fileprivate func validate(that parameter: Parameter, named parameterName: String, isAnObjectNamed objectName: String, withPropertyName objectPropertyName: String) {
    guard case .body(_, let schema) = parameter else {
        return XCTFail("\(parameterName) is not a .body.")
    }
    
    guard case .structure(let structure) = schema else {
        return XCTFail("\(parameterName)'s schema is not a .structure.")
    }
    
    XCTAssertEqual(structure.name, objectName)
    
    guard case .object(let object) = structure.structure else {
        return XCTFail("\(parameterName)'s schema's structure is not an .object.")
    }
    
    XCTAssertTrue(object.properties.contains { $0.key == objectPropertyName })
}

fileprivate func validate(that childSchema: Schema, named childName: String, withProperties childProperties: [String], hasParentNamed parentName: String, withProperties parentProperties: [String]) {
    guard case .allOf(let childAllOf) = childSchema else {
        return XCTFail("\(childName) is not an allOf.")
    }
    
    XCTAssertEqual(childAllOf.subschemas.count, 2)
    
    guard
        let childsParent = childAllOf.subschemas.first,
        case .structure(let childsParentStructure) = childsParent,
        childsParentStructure.name == parentName,
        case .object(let childsParentSchema) = childsParentStructure.structure else
    {
        return XCTFail("\(childName)'s parent is not a Structure<Schema.object>")
    }
    
    validate(that: childsParentSchema, named: parentName, hasRequiredProperties: parentProperties)
    
    guard let child = childAllOf.subschemas.last, case .object(let childSchema) = child else {
        return XCTFail("child is not a Structure<Schema.object>")
    }
    
    validate(that: childSchema, named: childName, hasRequiredProperties: childProperties)
}

/// MARK: Swagger Definitions Extension

fileprivate func validate(that definitions: [Structure<Schema>], containsTestAllOfChild name: String, withPropertyNames propertyNames: [String]) throws {
    guard let testAllOfChild = definitions.first(where: { $0.name == name }) else {
        return XCTFail("Definition named \(name) not found.")
    }
    
    let childSchemas = try getBaseAndChildSchemas(withDefinition: testAllOfChild)
    
    validate(testAllOfBaseSchema: childSchemas.base)
    validate(that: childSchemas.child, named: name, hasRequiredProperties: propertyNames)
}
