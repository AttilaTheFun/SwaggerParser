import ObjectMapper

public typealias BooleanItem = Metadata
typealias BooleanItemBuilder = MetadataBuilder

/// A limited subset of JSON-Schema's items object.
/// It is used by parameter definitions that are not located in "body".
public indirect enum Items {
    case string(item: StringItem)
    case number(item: NumberItem)
    case integer(item: IntegerItem)
    case array(item: ArrayItem)
    case boolean(item: BooleanItem)
}

indirect enum ItemsBuilder: Builder {

    typealias Building = Items

    case string(builder: StringItemBuilder)
    case number(builder: NumberItemBuilder)
    case integer(builder: IntegerItemBuilder)
    case array(builder: ArrayItemBuilder)
    case boolean(builder: BooleanItemBuilder)

    init(map: Map) throws {
        let metadata: BooleanItemBuilder = try MetadataBuilder(map: map)
        switch metadata.type {
        case .string:
            self = .string(builder: try StringItemBuilder(map: map))
        case .number:
            self = .number(builder: try NumberItemBuilder(map: map))
        case .integer:
            self = .integer(builder: try IntegerItemBuilder(map: map))
        case .array:
            self = .array(builder: try ArrayItemBuilder(map: map))
        case .boolean:
            self = .boolean(builder: metadata)
        case .enumeration, .object, .reference, .allOf:
            throw DecodingError()
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> Items {
        switch self {
        case .string(let builder):
            return .string(item: try builder.build(swagger))
        case .number(let builder):
            return .number(item: try builder.build(swagger))
        case .integer(let builder):
            return .integer(item: try builder.build(swagger))
        case .array(let builder):
            return .array(item: try builder.build(swagger))
        case .boolean(let builder):
            return .boolean(item: try builder.build(swagger))
        }
    }
}
