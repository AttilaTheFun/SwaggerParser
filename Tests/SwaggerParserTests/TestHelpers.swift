import XCTest
@testable import SwaggerParser

// MARK: - Fixture

func fixture(named fileName: String) throws -> String {
    let testFixtureFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
    let url = testFixtureFolder.appendingPathComponent(fileName)
    return try String.init(contentsOf: url, encoding: .utf8)
}

// MARK: - Schema Lookup

enum GetBaseAndChildSchemasError: Error {
    case missingBase
    case missingChild
    case badSubschemaType(Schema)
    case notAllOf
    case incorrectSubschemaCount
}

/// Gets the base schema and child schema from a definition that defines an
/// `allOf` with one $ref (the base class) and one object schema.
func getBaseAndChildSchemas(withDefinition definition: Structure<Schema>) throws -> (base: ObjectSchema, child: ObjectSchema) {
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
            guard case .object(let baseSchema) = structure.schema else {
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

// MARK: - Validation functions

func validate(testAllOfBaseSchema schema: ObjectSchema) {
    validate(that: schema, named: "TestAllOfBase", hasRequiredProperties: ["base", "test_type"])
}

func validate(that schema: ObjectSchema, named name: String, hasRequiredProperties properties: [String]) {
    XCTAssertEqual(schema.properties.count, properties.count)
    XCTAssertEqual(schema.required, properties)
    
    let keys = Set(schema.properties.keys)
    properties.forEach { XCTAssertTrue(keys.contains($0)) }
}

func validate(that parameter: Parameter, named parameterName: String, isAnObjectNamed objectName: String, withPropertyName objectPropertyName: String) {
    guard case .body(_, let schema) = parameter else {
        return XCTFail("\(parameterName) is not a .body.")
    }
    
    guard case .structure(let structure) = schema else {
        return XCTFail("\(parameterName)'s schema is not a .structure.")
    }
    
    XCTAssertEqual(structure.name, objectName)
    
    guard case .object(let object) = structure.schema else {
        return XCTFail("\(parameterName)'s schema's structure is not an .object.")
    }
    
    XCTAssertTrue(object.properties.contains { $0.key == objectPropertyName })
}

func validate(that childSchema: Schema, named childName: String, withProperties childProperties: [String], hasParentNamed parentName: String, withProperties parentProperties: [String]) {
    guard case .allOf(let childAllOf) = childSchema else {
        return XCTFail("\(childName) is not an allOf.")
    }
    
    XCTAssertEqual(childAllOf.subschemas.count, 2)
    
    guard
        let childsParent = childAllOf.subschemas.first,
        case .structure(let childsParentStructure) = childsParent,
        childsParentStructure.name == parentName,
        case .object(let childsParentSchema) = childsParentStructure.schema else
    {
        return XCTFail("\(childName)'s parent is not a Structure<Schema.object>")
    }
    
    validate(that: childsParentSchema, named: parentName, hasRequiredProperties: parentProperties)
    
    guard let discriminator = childsParentSchema.discriminator else {
        return XCTFail("\(parentName) has no discriminator.")
    }
    
    XCTAssertTrue(parentProperties.contains(discriminator))
    
    guard let child = childAllOf.subschemas.last, case .object(let childSchema) = child else {
        return XCTFail("child is not a Structure<Schema.object>")
    }
    
    validate(that: childSchema, named: childName, hasRequiredProperties: childProperties)
}

// MARK: - Swagger Definitions Extension

func validate(that definitions: [Structure<Schema>], containsTestAllOfChild name: String, withPropertyNames propertyNames: [String]) throws {
    guard let testAllOfChild = definitions.first(where: { $0.name == name }) else {
        return XCTFail("Definition named \(name) not found.")
    }
    
    let childSchemas = try getBaseAndChildSchemas(withDefinition: testAllOfChild)
    
    validate(testAllOfBaseSchema: childSchemas.base)
    validate(that: childSchemas.child, named: name, hasRequiredProperties: propertyNames)
}

