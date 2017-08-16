
public struct ArraySchema {

    /// Metadata about the array type including the number of items and their uniqueness.
    public let metadata: ArrayMetadata

    /// The type(s) of the items contained within the array.
    /// If one, the items must be homogeneous. If many, the array is an N-tuple.
    /// E.g. (Int, String, String, Int) for street number, street, city, zip.
    public let items: OneOrMany<Schema>

    /// Whether or not additional items are allowed in the array.
    /// Only really applicable to tuples.
    /// Either false or a type for the additional entries.
    /// If it is a type, the array may contain any number of additional items of the specified type up
    /// to maxItems.
    public let additionalItems: Either<Bool, Schema>
}

struct ArraySchemaBuilder: Codable {
    let metadataBuilder: ArrayMetadataBuilder
    let itemsBuilder: CodableOneOrMany<SchemaBuilder>
    let additionalItems: CodableEither<Bool, SchemaBuilder>

    enum CodingKeys: String, CodingKey {
        case itemsBuilder = "items"
        case additionalItems
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try ArrayMetadataBuilder(from: decoder)
        self.itemsBuilder = try values.decode(CodableOneOrMany<SchemaBuilder>.self, forKey: .itemsBuilder)
        self.additionalItems = try values.decodeIfPresent(CodableEither<Bool, SchemaBuilder>.self,
                                                          forKey: .additionalItems) ?? .a(false)
    }
}

extension ArraySchemaBuilder: Builder {
    typealias Building = ArraySchema

    func build(_ swagger: SwaggerBuilder) throws -> ArraySchema {
        let items: OneOrMany<Schema>
        switch self.itemsBuilder {
        case .one(let builder):
            items = .one(try builder.build(swagger))
        case .many(let builders):
            items = .many(try builders.map { try $0.build(swagger) })
        }

        let additionalItems: Either<Bool, Schema>
        switch self.additionalItems {
        case .a(let flag):
            additionalItems = .a(flag)
        case .b(let builder):
            additionalItems = .b(try builder.build(swagger))
        }

        return ArraySchema(
            metadata: try self.metadataBuilder.build(swagger),
            items: items,
            additionalItems: additionalItems)
    }
}
