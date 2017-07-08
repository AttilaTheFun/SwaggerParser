import ObjectMapper

public struct ArraySchema {
    public let items: OneOrMany<Schema>
    public let minItems: Int?
    public let maxItems: Int?
    public let additionalItems: Either<Bool, Schema>
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

        return ArraySchema(items: items, minItems: self.minItems,
                           maxItems: self.maxItems, additionalItems: additionalItems,
                           uniqueItems: self.uniqueItems)
    }
}

