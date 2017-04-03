import ObjectMapper

public enum Reference<T: ImmutableMappable>: ImmutableMappable {
    case pointer(Pointer<T>)
    case value(T)

    public init(map: Map) throws {
        if let pointer = try? Pointer<T>(map: map) {
            self = .pointer(pointer)
        } else {
            self = .value(try T(map: map))
        }
    }
}
