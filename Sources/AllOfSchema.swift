import ObjectMapper

public struct AllOfSchema {
    public let metadata: Metadata
    
    public let subschemas: [Schema]
}

public struct AllOfSchemaBuilder {
    
    typealias Building = AllOfSchema
    
    let metadata: MetadataBuilder
    let schemaBuilders: [SchemaBuilder]
    
    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        
        schemaBuilders = try map.value("allOf")
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let subschemas = try schemaBuilders.map { try $0.build(swagger) }
        return AllOfSchema(metadata: try self.metadata.build(swagger), subschemas: subschemas)
    }
    
}
