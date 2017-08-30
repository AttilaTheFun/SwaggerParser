
public struct ObjectSchema {

    /// Metadata about the object type including bounds on its number of properties and abstractness.
    public let metadata: ObjectMetadata

    /// By default, the properties defined are not required.
    /// However, one can provide a list of required properties using the required field.
    public let required: [String]

    /// A dictionary where each key is the name of a property and each value is a
    /// schema used to validate that property.
    public let properties: [String : Schema]

    /// The additionalProperties keyword is used to control the handling of extra stuff, 
    /// that is, properties whose names are not listed in the properties keyword. 
    /// By default any additional properties are allowed.
    /// The additionalProperties may be either a boolean or a schema.
    /// If additionalProperties is a boolean and set to false, no additional properties will be allowed.
    /// If additionalProperties is an object, that object is a schema that will be used to validate any 
    /// additional properties not listed in properties.
    public let additionalProperties: Either<Bool, Schema>
}

struct ObjectSchemaBuilder: Codable {
    let metadataBuilder: ObjectMetadataBuilder
    let required: [String]
    let properties: [String: SchemaBuilder]
    let additionalProperties: CodableEither<Bool, SchemaBuilder>

    enum CodingKeys: String, CodingKey {
        case required
        case properties
        case additionalProperties
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try ObjectMetadataBuilder(from: decoder)
        self.required = try values.decodeIfPresent([String].self, forKey: .required) ?? []
        self.properties = try values.decode([String: SchemaBuilder].self, forKey: .properties)
        self.additionalProperties = (try values.decodeIfPresent(CodableEither<Bool, SchemaBuilder>.self,
                                                                forKey: .additionalProperties)) ?? .a(false)
    }
}

extension ObjectSchemaBuilder: Builder {
    typealias Building = ObjectSchema

    func build(_ swagger: SwaggerBuilder) throws -> ObjectSchema {
        let properties = try self.properties.mapValues { try $0.build(swagger) }
        let additionalProperties: Either<Bool, Schema>
        switch self.additionalProperties {
        case .a(let flag):
            additionalProperties = .a(flag)
        case .b(let builder):
            additionalProperties = .b(try builder.build(swagger))
        }

        return ObjectSchema(
            metadata: try self.metadataBuilder.build(swagger),
            required: self.required,
            properties: properties,
            additionalProperties: additionalProperties)
    }
}
