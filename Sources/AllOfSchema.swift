
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

struct AllOfSchemaBuilder: Codable {
    let schemaBuilders: [SchemaBuilder]
    let abstract: Bool

    enum CodingKeys: String, CodingKey {
        case schemaBuilders = "allOf"
        case abstract = "x-abstract"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.schemaBuilders = try values.decode([SchemaBuilder].self, forKey: .schemaBuilders)
        self.abstract = (try values.decodeIfPresent(Bool.self, forKey: .abstract)) ?? false
    }
}

extension AllOfSchemaBuilder: Builder {
    typealias Building = AllOfSchema

    func build(_ swagger: SwaggerBuilder) throws -> AllOfSchema {
        let subschemas = try schemaBuilders.map { try $0.build(swagger) }
        return AllOfSchema(subschemas: subschemas, abstract: self.abstract)
    }
}
