import ObjectMapper


/// A limited subset of JSON-Schema's items object.
/// It is used by parameter definitions that are not located in "body".
public struct Items {
    public let metadata: Metadata
    public let type: ItemsType
}

public indirect enum ItemsType {
    case string(item: StringItem)
    case number(item: NumberItem)
    case integer(item: IntegerItem)
    case array(item: ArrayItem)
    case boolean
}

struct ItemsBuilder: Builder {

    typealias Building = Items

    let metadataBuilder: MetadataBuilder
    let typeBuilder: ItemsTypeBuilder

    init(map: Map) throws {
        metadataBuilder = try MetadataBuilder(map: map)
        switch metadataBuilder.type {
        case .string:
            typeBuilder = .string(builder: try StringItemBuilder(map: map))
        case .number:
            typeBuilder = .number(builder: try NumberItemBuilder(map: map))
        case .integer:
            typeBuilder = .integer(builder: try IntegerItemBuilder(map: map))
        case .array:
            typeBuilder = .array(builder: try ArrayItemBuilder(map: map))
        case .boolean:
            typeBuilder = .boolean
        case .enumeration, .object, .allOf, .pointer, .file, .any:
            throw DecodingError()
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> Items {
        return Items(metadata: try metadataBuilder.build(swagger),
                     type: try typeBuilder.build(swagger))
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
        switch DataType(map: map) {
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
            throw DecodingError()
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
