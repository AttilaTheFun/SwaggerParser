
/// Defines a type which is either of two subtytpes.
public enum Either<A, B> {
    case a(A)
    case b(B)
}

enum CodableEither<A: Codable, B: Codable>: Codable {
    case a(A)
    case b(B)

    init(from decoder: Decoder) throws {
        if let a = try? A(from: decoder) {
            self = .a(a)
            return
        }

        if let b = try? B(from: decoder) {
            self = .b(b)
            return
        }

        throw DecodingError("CodableOneOrMany: Neither case decoded successfully.")
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .a(let a):
            try a.encode(to: encoder)
        case .b(let b):
            try b.encode(to: encoder)
        }
    }
}
