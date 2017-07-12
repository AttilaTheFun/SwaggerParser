import ObjectMapper

struct Pointer<T: ImmutableMappable>: ImmutableMappable {

    let path: String

    init(map: Map) throws {
        path = try map.value("$ref")
    }
}
