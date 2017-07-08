import ObjectMapper

public struct ArrayItem {

    /// Describes the type of items in the array.
    public let items: Items

    /// Determines the format of the array if type array is used.
    public let collectionFormat: CollectionFormat

    /// Must be greater than or equal to zero.
    public let maxItems: Int?

    /// Must be greater than or equal to zero.
    public let minItems: Int

    public let uniqueItems: Bool
}

struct ArrayItemBuilder: Builder {

    typealias Building = ArrayItem

    let items: ItemsBuilder

    let collectionFormat: CollectionFormat
    let maxItems: Int?
    let minItems: Int
    let uniqueItems: Bool

    init(map: Map) throws {
        items = try map.value("items")
        collectionFormat = (try? map.value("collectionFormat")) ?? .csv

        maxItems = try? map.value("maxItems")
        minItems = (try? map.value("minItems")) ?? 0
        uniqueItems = (try? map.value("uniqueItems")) ?? false
    }

    func build(_ swagger: SwaggerBuilder) throws -> ArrayItem {
        return ArrayItem(items: try self.items.build(swagger),
                         collectionFormat: self.collectionFormat, maxItems: self.maxItems,
                         minItems: self.minItems, uniqueItems: self.uniqueItems)
    }
}
