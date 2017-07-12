import ObjectMapper

public struct ArraySchema {

    /// The type(s) of the items contained within the array.
    /// If one, the items must be homogeneous. If many, the array is an N-tuple.
    /// E.g. (Int, String, String, Int) for street number, street, city, zip.
    public let items: OneOrMany<Schema>

    /// The minimum number of items in the array.
    public let minItems: Int?

    /// The maximum number of items in the array.
    public let maxItems: Int?

    /// Whether or not additional items are allowed in the array.
    /// Only really applicable to tuples.
    /// Either false or a type for the additional entries.
    /// If it is a type, the array may contain any number of additional items of the specified type up
    /// to maxItems.
    public let additionalItems: Either<Bool, Schema>

    /// Whether the items must have unique values.
    public let uniqueItems: Bool?
}

struct ArraySchemaBuilder: Builder {

    typealias Building = ArraySchema

    let items: OneOrMany<SchemaBuilder>
    let minItems: Int?
    let maxItems: Int?
    let additionalItems: Either<Bool, SchemaBuilder>
    let uniqueItems: Bool?

    init(map: Map) throws {
        items = try OneOrMany(map: map, key: "items")
        minItems = try? map.value("minItems")
        maxItems = try? map.value("maxItems")
        additionalItems = (try? Either(map: map, key: "additionalItems")) ?? .a(false)
        uniqueItems = try? map.value("uniqueItems")
    }

    func build(_ swagger: SwaggerBuilder) throws -> ArraySchema {
        let items: OneOrMany<Schema>
        switch self.items {
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

        return ArraySchema(items: items, minItems: self.minItems,maxItems: self.maxItems,
                           additionalItems: additionalItems, uniqueItems: self.uniqueItems)
    }
}

