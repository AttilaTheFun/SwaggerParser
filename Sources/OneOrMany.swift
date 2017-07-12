import ObjectMapper

/// Defines a type that is either a single instance of a generic type or an array of that type.
public enum OneOrMany<T> {
    case one(T)
    case many([T])
}

extension OneOrMany where T: ImmutableMappable {
    public init(map: Map, key: String) throws {
        if let one: T = try? map.value(key) {
            self = .one(one)
        } else if let many: [T] = try? map.value(key) {
            self = .many(many)
        } else {
            throw DecodingError("OneOrMany: Neither case mapped successfully.")
        }
    }
}
