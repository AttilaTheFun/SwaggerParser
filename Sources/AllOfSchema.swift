import ObjectMapper

public struct AllOfSchema {

    /// The array of subschemas combined to form this schema.
    public let subschemas: [Schema]
    
    /// Determines whether or not the schema should be considered abstract. This
    /// can be used to indicate that a schema is an interface rather than a
    /// concrete model object.
    ///
    /// Corresponds to the boolean value for `x-abstract`. The default value is
    /// false.
    public let abstract: Bool
}

struct AllOfSchemaBuilder {
    
    typealias Building = AllOfSchema

    let schemaBuilders: [SchemaBuilder]
    let abstract: Bool
    
    init(map: Map) throws {
        schemaBuilders = try map.value("allOf")
        abstract = (try? map.value("x-abstract")) ?? false
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let subschemas = try schemaBuilders.map { try $0.build(swagger) }
        return AllOfSchema(subschemas: subschemas, abstract: self.abstract)
    }
}
