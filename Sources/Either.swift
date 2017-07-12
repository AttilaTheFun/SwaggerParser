import ObjectMapper

/// Defines a type which is either of two subtytpes.
public enum Either<A, B> {
    case a(A)
    case b(B)
}

extension Either where B: ImmutableMappable {
    public init(map: Map, key: String) throws {
        if let a: A = try? map.value(key) {
            self = .a(a)
        } else if let b: B = try? map.value(key) {
            self = .b(b)
        } else {
            throw DecodingError("Either: Neither type mapped successfully.")
        }
    }
}
