import ObjectMapper

public struct ObjectSchema {

    /// By default, the properties defined are not required.
    /// However, one can provide a list of required properties using the required field.
    public let required: [String]

    /// A dictionary where each key is the name of a property and each value is a
    /// schema used to validate that property.
    public let properties: [String : Schema]

    /// The minimum number of properties. If set it must be a non-negative integer.
    public let minProperties: Int?

    /// The maximum number of properties. If set it must be a non-negative integer.
    public let maxProperties: Int?

    /// The additionalProperties keyword is used to control the handling of extra stuff, 
    /// that is, properties whose names are not listed in the properties keyword. 
    /// By default any additional properties are allowed.
    /// The additionalProperties may be either a boolean or a schema.
    /// If additionalProperties is a boolean and set to false, no additional properties will be allowed.
    /// If additionalProperties is an object, that object is a schema that will be used to validate any 
    /// additional properties not listed in properties.
    public let additionalProperties: Either<Bool, Schema>

    /// Adds support for polymorphism. 
    /// The discriminator is the schema property name that is used to differentiate between other schema 
    /// that inherit this schema. The property name used MUST be defined at this schema and it MUST be in the 
    /// required property list. When used, the value MUST be the name of this schema or any schema that 
    /// inherits it.
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

        return ObjectSchema(required: self.required, properties: properties, minProperties: self.minProperties,
                            maxProperties: self.maxProperties, additionalProperties: additionalProperties,
                            discriminator: self.discriminator, abstract: self.abstract)
    }
}
