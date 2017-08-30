
/// Schemas are used to define the types used in body parameters. They are more expressive than Items.
public struct Schema {

    /// Metadata is used to provide common meta (name, nullability, etc) information about the type.
    public let metadata: Metadata

    /// The type defined by this schema along with any specific type information (e.g. object properties).
    public let type: SchemaType

    /// Additional external documentation for this schema.
    public let externalDocumentation: ExternalDocumentation?
}

struct SchemaBuilder: Codable {
    let metadataBuilder: MetadataBuilder
    let schemaTypeBuilder: SchemaTypeBuilder
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    enum CodingKeys: String, CodingKey {
        case externalDocumentation = "externalDocs"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try MetadataBuilder(from: decoder)
        self.schemaTypeBuilder = try SchemaTypeBuilder(from: decoder)
        self.externalDocumentationBuilder = try values.decodeIfPresent(ExternalDocumentationBuilder.self,
                                                                       forKey: .externalDocumentation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.externalDocumentationBuilder, forKey: .externalDocumentation)
        try self.metadataBuilder.encode(to: encoder)
        try self.schemaTypeBuilder.encode(to: encoder)
    }
}

extension SchemaBuilder: Builder {
    typealias Building = Schema

    func build(_ swagger: SwaggerBuilder) throws -> Schema {
        return Schema(metadata: try self.metadataBuilder.build(swagger),
                      type: try self.schemaTypeBuilder.build(swagger),
                      externalDocumentation: try self.externalDocumentationBuilder?.build(swagger))
    }
}
