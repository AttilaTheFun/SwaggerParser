import ObjectMapper

public struct ObjectSchema {
    public let required: [String]
    public let properties: [String : Schema]
    public let minProperties: Int?
    public let maxProperties: Int?
    public let additionalProperties: Either<Bool, Schema>
    public let discriminator: String?
    
    /// Determines whether or not the schema should be considered abstract. This
    /// can be used to indicate that a schema is an interface rather than a
    /// concrete model object.
    ///
    /// Corresponds to the boolean value for `x-abstract`. The default value is
    /// false.
    public let abstract: Bool
}

struct ObjectSchemaBuilder: Builder {

    typealias Building = ObjectSchema

    let required: [String]
    let properties: [String : SchemaBuilder]
    let minProperties: Int?
    let maxProperties: Int?
    let additionalProperties: Either<Bool, SchemaBuilder>
    let discriminator: String?
    let abstract: Bool

    init(map: Map) throws {
        required = (try? map.value("required")) ?? []
        properties = (try? map.value("properties")) ?? [:]
        minProperties = try? map.value("minProperties")
        maxProperties = try? map.value("maxProperties")
        additionalProperties = (try? Either(map: map, key: "additionalProperties")) ?? .a(false)
        discriminator = try? map.value("discriminator")
        abstract = (try? map.value("x-abstract")) ?? false
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

        return ObjectSchema(required: self.required,
                            properties: properties, minProperties: self.minProperties,
                            maxProperties: self.maxProperties, additionalProperties: additionalProperties,
                            discriminator: self.discriminator, abstract: self.abstract)
    }
}
