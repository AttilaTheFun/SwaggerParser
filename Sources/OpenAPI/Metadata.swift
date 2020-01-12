
public struct Metadata {

    /// The data type of the schema.
    public let type: DataType

    /// A short description of the schema.
    public let title: String?

    /// A more lengthy explanation about the purpose of the data described by the schema
    public let description: String?

    /// Used to specify the default value for the parent schema.
    public let defaultValue: Any?

    /// Used to restrict the schema to a specific set of values.
    public let enumeratedValues: [Any?]?
    
    /// Whether or not the schema can be nil. Corresponds to `x-nullable`.
    public let nullable: Bool
    
    /// An example value for the schema.
    public let example: Any?
}

public struct MetadataBuilder: Codable {
    let type: DataType
    let title: String?
    let description: String?
    let defaultValue: Any?
    let enumeratedValues: [Any?]?
    let nullable: Bool
    let example: Any?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case defaultValue = "default"
        case enumeratedValues = "enum"
        case nullable = "x-nullable"
        case example = "example"
        case xExample = "x-example"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try DataType(from: decoder)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.defaultValue = try values.decodeAnyIfPresent(forKey: .defaultValue)
        self.enumeratedValues = try values.decodeArrayOfOptionalAnyIfPresent(forKey: .enumeratedValues)
        self.nullable = try values.decodeIfPresent(Bool.self, forKey: .nullable) ?? false
        self.example = try values.decodeAnyIfPresent(forKey: .xExample) ??
            (try values.decodeAnyIfPresent(forKey: .example))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encodeAnyIfPresent(self.defaultValue, forKey: .defaultValue)
        try container.encodeArrayOfOptionalAnyIfPresent(self.enumeratedValues, forKey: .enumeratedValues)
        try container.encode(self.nullable, forKey: .nullable)
        try container.encodeAnyIfPresent(self.example, forKey: .example)
    }
}

extension MetadataBuilder: Builder {
    public typealias Building = Metadata

    public func build(_ swagger: SwaggerBuilder) throws -> Metadata {
        return Metadata(
            type: self.type,
            title: self.title,
            description: self.description,
            defaultValue: self.defaultValue,
            enumeratedValues: self.enumeratedValues,
            nullable: self.nullable,
            example: self.example)
    }
}
