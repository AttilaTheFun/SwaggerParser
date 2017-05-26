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
        
        let fooDefinition = swagger.definitions.first(where: {$0.name == "TestAllOfFoo"})!
        guard case .allOf(let fooSchema) = fooDefinition.structure else {
            XCTFail("TestAllOfFoo is not an object schema."); return
        }
        XCTAssertEqual(fooSchema.metadata.description, "This is an AllOf description.")
    }
    
    func testExamples() {
        let url = testFixtureFolder.appendingPathComponent("test_examples.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        let definition = swagger.definitions.first(where: {$0.name == "Example"})!
        guard case .object(let schema) = definition.structure else {
            XCTFail("Example is not an object schema."); return
        }
        
        guard case .string(let aStringMetadata, let aStringOptionalFormat) = schema.properties["a-string"]! else {
            XCTFail("Example has no string property 'a-string'."); return
        }
        
        guard
            let aStringFormat = aStringOptionalFormat,
            case .other(let aStringFormatValue) = aStringFormat,
            aStringFormatValue == "custom" else {
                XCTFail("Example's 'a-string' does not have `custom` format type."); return
        }
        
        XCTAssertEqual(aStringMetadata.example as? String, "Example String")
        
        guard case .integer(let anIntegerMetadata, _) = schema.properties["an-integer"]! else {
            XCTFail("Example has no string property 'an-integer'."); return
        }
        
        XCTAssertEqual(anIntegerMetadata.example as? Int64, 987)
        
        let exampleIDOperation = swagger.paths["/test-examples/{exampleId}"]!.operations[.post]!
        XCTAssertEqual(exampleIDOperation.parameters.count, 1)
        
        guard case .a(let exampleIDParameter) = exampleIDOperation.parameters.first! else {
            XCTFail("Example ID parameter should not be a structure."); return
        }
        
        guard case .other(let exampleIDFixed, _) = exampleIDParameter else {
            XCTFail("Example ID parameter is not .other."); return
        }
        
        XCTAssertEqual(exampleIDFixed.example as? String, "E_123")
    }
    
    func testAbstract() {
        let url = testFixtureFolder.appendingPathComponent("test_abstract.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        guard
            let objectDefinition = swagger.definitions.first(where: {$0.name == "Abstract"}),
            case .object(let objectSchema) = objectDefinition.structure else {
                XCTFail("Abstract is not an object schema."); return
        }
        XCTAssertTrue(objectSchema.abstract)
        
        let allOfDefinition = swagger.definitions.first(where: {$0.name == "AbstractAllOf"})!
        guard case .allOf(let allOfSchema) = allOfDefinition.structure else {
            XCTFail("AbstractAllOf is not an allOf schema."); return
        }
        XCTAssertTrue(allOfSchema.abstract)
    }
    
    func testNullable() {
        let url = testFixtureFolder.appendingPathComponent("test_nullable.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        let definition = swagger.definitions.first(where: {$0.name == "Test"})!
        guard case .object(let object) = definition.structure else {
            XCTFail("Test is not an object schema."); return
        }
        
        guard
            let foo = object.properties["foo"],
            case .string(let fooMetadata, _) = foo else {
                fatalError("Test has no string property foo.")
        }
        XCTAssertTrue(fooMetadata.nullable)
        
        guard
            let bar = object.properties["bar"],
            case .string(let barMetadata, _) = bar else {
                fatalError("Test has no string property bar.")
        }
        XCTAssertFalse(barMetadata.nullable)
        
        guard
            let qux = object.properties["qux"],
            case .string(let quxMetadata, _) = qux else {
                fatalError("Test has no string property qux.")
        }
        XCTAssertFalse(quxMetadata.nullable)
    }
    
    func testReferenceMetadata() {
        let url = testFixtureFolder.appendingPathComponent("test_reference_metadata.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        let definition = swagger.definitions.first(where: {$0.name == "Test"})!
        guard case .object(let object) = definition.structure else {
            XCTFail("Test is not an object schema."); return
        }
        
        guard
            let referenceProperty = object.properties["reference"],
            case .structure(let referenceStructure) = referenceProperty else {
                fatalError("Test has no string property foo.")
        }
        XCTAssertEqual(referenceStructure.metadata.description, "A reference comment.")
        XCTAssertTrue(referenceStructure.metadata.nullable)
    }
    
    func testParameterReferences() {
        let url = testFixtureFolder.appendingPathComponent("test_parameter_references.json")
        let jsonString = try! NSString(contentsOfFile: url.path, encoding: String.Encoding.utf8.rawValue) as String
        let swagger = try! Swagger(JSONString: jsonString)
        
        let parameterName = "testParam"
        let parameter = swagger.parameters.first(where: {$0.name == "testParam"})!.structure
        let objectName = "Test"
        let propertyName = "foo"
        SwaggerParserTests.validate(thatParameter: parameter, named: parameterName, isAnObjectNamed: objectName, withPropertyName: propertyName)
        
        guard let eitherParameter = swagger.paths["/test-parameter-reference"]?.operations[.post]?.parameters.first else {
            XCTFail("POST /test-parameter-reference parameter not found."); return
        }
        guard case .b(let parameterStructure) = eitherParameter else {
            XCTFail("POST /test-parameter-reference parameter not found."); return
        }
        XCTAssertEqual(parameterStructure.name, parameterName)
        SwaggerParserTests.validate(thatParameter: parameterStructure.structure, named: parameterName, isAnObjectNamed: objectName, withPropertyName: propertyName)
    }
    
    func testSeparated() {
        let url = testFixtureFolder.appendingPathComponent("Separated").appendingPathComponent("test.json")
        let swagger = try! Swagger(URL: url)
        XCTAssertEqual(swagger.host?.absoluteString, "api.test.com")
        
        XCTAssertEqual(swagger.definitions.count, 5)
        
        let parentName = "parent"
        let parentPropertyNames = ["type"]
        
        guard case .object(let parent) = swagger.definitions.first(where: {$0.name == parentName})!.structure else {
            XCTFail("child is not an object."); return
        }
        SwaggerParserTests.validate(thatSchema: parent, named: parentName, hasRequiredProperties: parentPropertyNames)
        
        let childName = "child"
        let childPropertyNames = ["reference"]
        let childSchema = swagger.definitions.first(where: {$0.name == childName})!.structure
        
        SwaggerParserTests.validate(
            thatChildSchema: childSchema,
            named: childName,
            withProperties: childPropertyNames,
            hasParentNamed: parentName,
            withProperties: parentPropertyNames)
        
        guard
            let either = swagger.paths["/test"]?.operations[.get]?.responses[200],
            case .a(let response) = either else {
                XCTFail("response not found for GET /test 200."); return
        }
        guard
            let responseSchema = response.schema,
            case .structure(let responseSchemaStructure) = responseSchema else {
                XCTFail("response schema is not a structure."); return
        }
        XCTAssertEqual(responseSchemaStructure.name, childName)
        
        let responseChildSchema = responseSchemaStructure.schema
        
        SwaggerParserTests.validate(
            thatChildSchema: responseChildSchema,
            named: childName,
            withProperties: childPropertyNames,
            hasParentNamed: parentName,
            withProperties: parentPropertyNames)
        
        guard case .object(let definitionRef) = swagger.definitions.first(where: {$0.name == "definitions-reference"})!.structure else {
            XCTFail("`definitions-reference` is not an object."); return
        }
        XCTAssertNotNil(definitionRef.properties.first(where: {$0.key == "bar"})?.value)
        
        guard case .allOf(let allOf) = responseChildSchema else {
            XCTFail("Response schema is not an .allOf"); return
        }
        XCTAssertEqual(allOf.schemas.count, 2)
        
        guard
            let childAllOfSchema = allOf.schemas.last,
            case .object(let child) = childAllOfSchema else {
                XCTFail("Response schema's .allOf's last item is not an .object"); return
        }
        
        guard let referenceProperty = child.properties.first(where: {$0.key == "reference"})?.value else {
            XCTFail("Response schema's .allOf's last item does not have a 'reference' property."); return
        }
        
        guard
            case .structure(let referenceStructure) = referenceProperty,
            referenceStructure.name == "reference",
            case .object(let reference) = referenceStructure.schema else {
                XCTFail("Response schema's .allOf's last item's 'reference' property is not a Structure<Schema.object>."); return
        }
        
        guard
            let arrayProperty = reference.properties.first(where: {$0.key == "array-items"})?.value,
            case .array(let arraySchema) = arrayProperty,
            case .one(let arrayItemSchema) = arraySchema.items else {
                XCTFail("Array property not found on reference."); return
        }
        
        guard
            case .structure(let arrayStructure) = arrayItemSchema,
            arrayStructure.name == "array-item",
            case .object(let arrayItemObjectSchema) = arrayStructure.schema else {
                XCTFail("`array-items` poprety does not contain an object reference."); return
        }
        
        XCTAssertNotNil(arrayItemObjectSchema.properties.first(where: {$0.key == "foo"})?.value)
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
                    guard case .object(let baseSchema) = structure.schema else {fatalError()}
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
        XCTAssertEqual(schema.discriminator, "test_type")
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
        
        guard case .object(let object) = structure.schema else {
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
            case .object(let childsParentSchema) = childsParentStructure.schema else {
                XCTFail("\(childName)'s parent is not a Structure<Schema.object>"); return
        }
        SwaggerParserTests.validate(thatSchema: childsParentSchema, named: parentName, hasRequiredProperties: parentProperties)
        
        guard let discriminator = childsParentSchema.discriminator else {
            XCTFail("\(parentName) has no discriminator."); return
        }
        XCTAssertTrue(parentProperties.contains(discriminator))
        
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
