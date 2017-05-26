import ObjectMapper

public struct AllOfSchema {
    public let metadata: Metadata
    
    public let schemas: [Schema]
    
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
        
        let allOf: [[String:Any]] = try map.value("allOf")
        schemaBuilders = allOf
            .map {Map(mappingType: .fromJSON, JSON: $0)}
            .flatMap { map -> SchemaBuilder? in
                guard let schemaBuilder = try? SchemaBuilder(map: map) else {
                    return nil
                }
                return schemaBuilder
            }
        abstract = (try? map.value("x-abstract")) ?? false
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let schemas = try schemaBuilders.map {try $0.build(swagger)}
        return AllOfSchema(metadata: try self.metadata.build(swagger), schemas: schemas,
                           abstract: self.abstract)
    }
    
}
