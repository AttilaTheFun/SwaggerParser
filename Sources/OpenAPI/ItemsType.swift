
public indirect enum ItemsType {

    /// A complex (but restrictive) array type.
    case array(item: ArrayItem)

    /// A primitive string type.
    case string(item: StringItem)

    /// A primitive floating point number type.
    case number(item: NumberItem)

    /// A primitive integer type.
    case integer(item: IntegerItem)

    /// A primitive boolean type.
    case boolean
}

public indirect enum ItemsTypeBuilder: Codable {
    case string(StringItemBuilder)
    case number(NumberItemBuilder)
    case integer(IntegerItemBuilder)
    case array(ArrayItemBuilder)
    case boolean

    public init(from decoder: Decoder) throws {
        let dataType = try DataType(from: decoder)
        switch dataType {
        case .string:
            self = .string(try StringItemBuilder(from: decoder))
        case .number:
            self = .number(try NumberItemBuilder(from: decoder))
        case .integer:
            self = .integer(try IntegerItemBuilder(from: decoder))
        case .array:
            self = .array(try ArrayItemBuilder(from: decoder))
        case .boolean:
            self = .boolean
        case .enumeration, .object, .allOf, .pointer, .file, .any, .null:
            throw DecodingError("ItemsTypeBuilder: Unsupported data type \(dataType.rawValue)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let builder):
            try builder.encode(to: encoder)
        case .number(let builder):
            try builder.encode(to: encoder)
        case .integer(let builder):
            try builder.encode(to: encoder)
        case .array(let builder):
            try builder.encode(to: encoder)
        case .boolean:
            // Will be encoded by Item -> Metadata -> DataType
            break
        }
    }
}

extension ItemsTypeBuilder: Builder {
    public typealias Building = ItemsType

    public func build(_ swagger: SwaggerBuilder) throws -> ItemsType {
        switch self {
        case .string(let builder):
            return .string(item: try builder.build(swagger))
        case .number(let builder):
            return .number(item: try builder.build(swagger))
        case .integer(let builder):
            return .integer(item: try builder.build(swagger))
        case .array(let builder):
            return .array(item: try builder.build(swagger))
        case .boolean:
            return .boolean
        }
    }
}
