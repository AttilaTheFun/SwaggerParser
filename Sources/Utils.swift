import ObjectMapper

public struct DecodingError: Error {}

public enum Either<A, B> where B: ImmutableMappable {
    case a(A)
    case b(B)

    public init(map: Map, key: String) throws {
        if let a: A = try? map.value(key) {
            self = .a(a)
        } else if let b: B = try? map.value(key) {
            self = .b(b)
        } else {
            throw DecodingError()
        }
    }
}

public struct Pointer<T: ImmutableMappable>: ImmutableMappable {
    public let path: String

    public init(map: Map) throws {
        path = try map.value("$ref")
    }
}

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

public enum OneOrMany<T> where T: ImmutableMappable {
    case one(T)
    case many([T])

    public init(map: Map, key: String) throws {
        if let one: T = try? map.value(key) {
            self = .one(one)
        } else if let many: [T] = try? map.value(key) {
            self = .many(many)
        } else {
            throw DecodingError()
        }
    }
}


