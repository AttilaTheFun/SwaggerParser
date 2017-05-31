import ObjectMapper

public struct AllOfSchema {
    public let metadata: Metadata
    public let subschemas: [Schema]
    
    /// Determines whether or not the schema should be considered abstract code
    /// generation purposes. This can be used to indicate that a schema is an
    /// interface rather than a concrete model object.
    ///
    /// Corresponds to the boolean value for `x-abstract`. The default value is
    /// false.
    public let abstract: Bool
}

public struct AllOfSchemaBuilder {
    
    typealias Building = AllOfSchema
    
    let metadata: MetadataBuilder
    let schemaBuilders: [SchemaBuilder]
    
    /// See AllOfSchema.abstract
    let abstract: Bool
    
    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        
        schemaBuilders = try map.value("allOf")
        abstract = (try? map.value("x-abstract")) ?? false
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let subschemas = try schemaBuilders.map { try $0.build(swagger) }
        return AllOfSchema(metadata: try self.metadata.build(swagger), subschemas: subschemas,
                           abstract: self.abstract)
    }
}
