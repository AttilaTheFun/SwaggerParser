import ObjectMapper

public struct Pointer<T: ImmutableMappable>: ImmutableMappable {

    public let path: String

    public init(map: Map) throws {
        path = try map.value("$ref")
    }
}
