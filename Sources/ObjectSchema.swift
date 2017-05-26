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
    let required: Set<String>
    let properties: [String : SchemaBuilder]
    let minProperties: Int?
    let maxProperties: Int?
    let additionalProperties: Either<Bool, SchemaBuilder>?

    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        let requiredArray: [String] = (try? map.value("required")) ?? []
        required = Set(requiredArray)
        properties = (try? map.value("properties")) ?? [:]
        minProperties = try? map.value("minProperties")
        maxProperties = try? map.value("maxProperties")
        additionalProperties = try? Either(map: map, key: "additionalProperties")
    }

    func build(_ swagger: SwaggerBuilder) throws -> ObjectSchema {
        let properties = try Dictionary(self.properties.map { (key, value) in
            return (key, try value.build(swagger))
        })

        let additionalProperties: Either<Bool, Schema>
        switch self.additionalProperties {
        case .some(.a(let flag)):
            additionalProperties = .a(flag)
        case .some(.b(let builder)):
            additionalProperties = .b(try builder.build(swagger))
        case .none:
            additionalProperties = .a(false)
        }

        return ObjectSchema(metadata: try self.metadata.build(swagger), required: Array(self.required),
                            properties: properties, minProperties: self.minProperties,
                            maxProperties: self.maxProperties, additionalProperties: additionalProperties)
    }
}

struct AllOfSchemaBuilder: Builder {

    typealias Building = ObjectSchema

    let metadata: MetadataBuilder
    // TODO: Can allOf have both the allOf field and a properties field?
    let schemaBuilders: [SchemaBuilder]
    let minProperties: Int?
    let maxProperties: Int?
    let additionalProperties: Either<Bool, SchemaBuilder>?

    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        schemaBuilders = try map.value("allOf")
        minProperties = try? map.value("minProperties")
        maxProperties = try? map.value("maxProperties")
        additionalProperties = try? Either(map: map, key: "additionalProperties")
    }

    func build(_ swagger: SwaggerBuilder) throws -> ObjectSchema {

        func extractObjectSchema(schemaBuilder: SchemaBuilder) throws -> ObjectSchemaBuilder {
            switch schemaBuilder {
            case .allOf:
                // TODO: Is this a thing?
                throw DecodingError()
            case .pointer(let pointer):
                let resolvedBuilder = try SchemaBuilder.resolveIntoBuilder(swagger: swagger, pointer: pointer)
                return try extractObjectSchema(schemaBuilder: resolvedBuilder)
            case .object(let objectSchemaBuilder):
                return objectSchemaBuilder
            default:
                // The schemae should all be objects.
                throw DecodingError()
            }
        }

        let builders = try schemaBuilders.map(extractObjectSchema)
        if builders.isEmpty {
            throw DecodingError()
        }

        var combinedRequired = Set<String>()
        var combinedProperties = [String : SchemaBuilder]()

        for builder in builders {
            combinedRequired = combinedRequired.union(builder.required)
            builder.properties.forEach { (key, newProperty) in
                // TODO: Verify that existing schema is the same, throw error if not.
                combinedProperties[key] = newProperty
            }
        }

        let properties = try Dictionary(combinedProperties.map { (key, value) in
            return (key, try value.build(swagger))
        })

        let additionalProperties: Either<Bool, Schema>
        switch self.additionalProperties {
        case .some(.a(let flag)):
            additionalProperties = .a(flag)
        case .some(.b(let builder)):
            additionalProperties = .b(try builder.build(swagger))
        case .none:
            additionalProperties = .a(false)
        }

        return ObjectSchema(metadata: try self.metadata.build(swagger), required: Array(combinedRequired),
                            properties: properties, minProperties: self.minProperties,
                            maxProperties: self.maxProperties, additionalProperties: additionalProperties)
    }
}
