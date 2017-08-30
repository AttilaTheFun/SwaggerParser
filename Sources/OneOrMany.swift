
/// Defines a type that is either a single instance of a generic type or an array of that type.
public enum OneOrMany<T> {
    case one(T)
    case many([T])
}

enum CodableOneOrMany<T: Codable>: Codable {
    case one(T)
    case many([T])

    init(from decoder: Decoder) throws {
        if let one = try? T(from: decoder) {
            self = .one(one)
            return
        }

        if let many = try? Array<T>(from: decoder) {
            self = .many(many)
            return
        }

        throw DecodingError("OneOrMany: Neither case decoded successfully.")
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .one(let one):
            try one.encode(to: encoder)
        case .many(let many):
            try many.encode(to: encoder)
        }
    }
}
