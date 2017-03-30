import ObjectMapper

public struct Header: ImmutableMappable {
    public let description: String?
    public let items: Items

    public init(map: Map) throws {
        description = try? map.value("description")
        items = try Items(map: map)
    }
}
