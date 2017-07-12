import ObjectMapper


/// A limited subset of JSON-Schema's items object.
/// It is used by parameter definitions that are not located in "body".
public struct Items {

    /// Metadata is used to provide common meta (name, nullability, etc) information about the type.
    public let metadata: Metadata

    /// The type defined by this schema along with any specific type information (e.g. array items).
    public let type: ItemsType
}

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

struct ItemsBuilder: Builder {

    typealias Building = Items

    let metadataBuilder: MetadataBuilder
    let typeBuilder: ItemsTypeBuilder

    init(map: Map) throws {
        metadataBuilder = try MetadataBuilder(map: map)
        typeBuilder = try ItemsTypeBuilder(map: map)
    }

    func build(_ swagger: SwaggerBuilder) throws -> Items {
        return Items(metadata: try metadataBuilder.build(swagger), type: try typeBuilder.build(swagger))
    }
}

indirect enum ItemsTypeBuilder: Builder {

    typealias Building = ItemsType

    case string(builder: StringItemBuilder)
    case number(builder: NumberItemBuilder)
    case integer(builder: IntegerItemBuilder)
    case array(builder: ArrayItemBuilder)
    case boolean

    init(map: Map) throws {
        let dataType = DataType(map: map)
        switch dataType {
        case .string:
            self = .string(builder: try StringItemBuilder(map: map))
        case .number:
            self = .number(builder: try NumberItemBuilder(map: map))
        case .integer:
            self = .integer(builder: try IntegerItemBuilder(map: map))
        case .array:
            self = .array(builder: try ArrayItemBuilder(map: map))
        case .boolean:
            self = .boolean
        case .enumeration, .object, .allOf, .pointer, .file, .any:
            throw DecodingError("ItemsTypeBuilder: Unsupported data type \(dataType.rawValue)")
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> ItemsType {
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
