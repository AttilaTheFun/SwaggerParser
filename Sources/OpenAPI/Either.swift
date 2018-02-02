
/// Defines a type which is either of two subtytpes.
public enum Either<A, B> {
    case a(A)
    case b(B)
}

public enum CodableEither<A: Codable, B: Codable>: Codable {
    case a(A)
    case b(B)

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .a(let a):
            try a.encode(to: encoder)
        case .b(let b):
            try b.encode(to: encoder)
        }
    }
}

/// Retrieves value of A for Either<A, Structure<A>> types
public extension Either where B == Structure<A> {
    
    var structure: A {
        switch self {
        case .a(let vA):
            return vA
        case .b(let vB):
            return vB.structure
        }
    }
    
}
