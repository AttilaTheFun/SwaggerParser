import ObjectMapper

enum Reference<T: ImmutableMappable>: ImmutableMappable {

    case pointer(Pointer<T>)
    case value(T)

    init(map: Map) throws {
        if let pointer = try? Pointer<T>(map: map) {
            self = .pointer(pointer)
        } else {
            self = .value(try T(map: map))
        }
    }
}
