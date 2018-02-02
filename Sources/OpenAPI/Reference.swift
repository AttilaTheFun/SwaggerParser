
public enum Reference<T: Codable>: Codable {
    case pointer(Pointer<T>)
    case value(T)

    public init(from decoder: Decoder) throws {
        if let pointer = try? Pointer<T>(from: decoder) {
            self = .pointer(pointer)
        } else {
            self = .value(try T(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .pointer(let pointer):
            try pointer.encode(to: encoder)
        case .value(let value):
            try value.encode(to: encoder)
        }
    }
}
