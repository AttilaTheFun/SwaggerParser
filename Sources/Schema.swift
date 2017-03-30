import ObjectMapper

public struct ArraySchema {
    public let metadata: Metadata
    public let items: OneOrMany<Schema>
    public let minItems: Int?
    public let maxItems: Int?
    public let additionalItems: Either<Bool, Schema>?
    public let uniqueItems: Bool?

    public init(map: Map, metadata data: Metadata) throws {
        metadata = data
        items = try OneOrMany(map: map, key: "items")
        minItems = try? map.value("minItems")
        maxItems = try? map.value("maxItems")
        additionalItems = try? Either(map: map, key: "additionalItems")
        uniqueItems = try? map.value("uniqueItems")
    }
}

public struct ObjectSchema {
    public let metadata: Metadata
    public let required: [String]?
    public let properties: [String : Schema]?
    public let minProperties: Int?
    public let maxProperties: Int?
    public let additionalProperties: Either<Bool, Schema>?

    public init(map: Map, metadata data: Metadata) throws {
        metadata = data
        required = try? map.value("required")
        properties = try? map.value("properties")
        minProperties = try? map.value("minProperties")
        maxProperties = try? map.value("maxProperties")
        additionalProperties = try? Either(map: map, key: "additionalProperties")
    }
}

/// Schemas are used to define the types used in body parameters. They are more expressive than Items.
public enum Schema: ImmutableMappable {
    indirect case object(ObjectSchema)
    indirect case array(ArraySchema)
    indirect case pointer(Pointer<Schema>)
    case string(metadata: Metadata, format: StringFormat?)
    case number(metadata: Metadata, format: NumberFormat?)
    case integer(metadata: Metadata, format: IntegerFormat?)
    case enumeration(metadata: Metadata)
    case boolean(metadata: Metadata)

    public init(map: Map) throws {
        // Check if a reference
        if let pointer = try? Pointer<Schema>(map: map) {
            self = .pointer(pointer)
            return
        }

        // Map according to the type:
        let metadata = try Metadata(map: map)
        switch metadata.type {
        case .array:
            self = .array(try ArraySchema(map: map, metadata: metadata))
        case .object:
            self = .object(try ObjectSchema(map: map, metadata: metadata))
        case .string:
            self = .string(metadata: metadata, format: try? map.value("format"))
        case .number:
            self = .number(metadata: metadata, format: try? map.value("format"))
        case .integer:
            self = .integer(metadata: metadata, format: try? map.value("format"))
        case .enumeration:
            self = .enumeration(metadata: metadata)
        case .boolean:
            self = .boolean(metadata: metadata)
        }
    }
}
