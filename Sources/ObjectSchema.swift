import ObjectMapper

public struct ObjectSchema {
    public let metadata: Metadata
    public let required: [String]
    public let properties: [String : Schema]
    public let minProperties: Int?
    public let maxProperties: Int?
    public let additionalProperties: Either<Bool, Schema>
}

struct ObjectSchemaBuilder: Builder {

    typealias Building = ObjectSchema

    let metadata: MetadataBuilder
    let required: [String]
    let properties: [String : SchemaBuilder]
    let minProperties: Int?
    let maxProperties: Int?
    let additionalProperties: Either<Bool, SchemaBuilder>

    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        required = (try? map.value("required")) ?? []
        properties = (try? map.value("properties")) ?? [:]
        minProperties = try? map.value("minProperties")
        maxProperties = try? map.value("maxProperties")
        additionalProperties = (try? Either(map: map, key: "additionalProperties")) ?? .a(false)
    }

    func build(_ swagger: SwaggerBuilder) throws -> ObjectSchema {
        let properties = try Dictionary(self.properties.map { (key, value) in
            return (key, try value.build(swagger))
        })

        let additionalProperties: Either<Bool, Schema>
        switch self.additionalProperties {
        case .a(let flag):
            additionalProperties = .a(flag)
        case .b(let builder):
            additionalProperties = .b(try builder.build(swagger))
        }

        return ObjectSchema(metadata: try self.metadata.build(swagger), required: self.required,
                            properties: properties, minProperties: self.minProperties,
                            maxProperties: self.maxProperties, additionalProperties: additionalProperties)
    }
}
