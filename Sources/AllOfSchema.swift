import ObjectMapper

public struct AllOfSchema {
    public let metadata: Metadata
    
    public let schemas: [Schema]
}

public struct AllOfSchemaBuilder {
    
    typealias Building = AllOfSchema
    
    let metadata: MetadataBuilder
    let schemaBuilders: [SchemaBuilder]
    
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
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let schemas = try schemaBuilders.map {try $0.build(swagger)}
        return AllOfSchema(metadata: try self.metadata.build(swagger), schemas: schemas)
    }
    
}
