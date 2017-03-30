import ObjectMapper

public struct IntegerMetadata: ImmutableMappable {
    public let maximum: Int?
    public let exclusiveMaximum: Int?
    public let minimum: Int?
    public let exclusiveMinimum: Int?

    /// Must be greater than zero.
    public let multipleOf: Int?

    public init(map: Map) throws {
        maximum = try? map.value("maximum")
        exclusiveMaximum = try? map.value("exclusiveMaximum")
        minimum = try? map.value("minimum")
        exclusiveMinimum = try? map.value("exclusiveMinimum")
        multipleOf = try? map.value("multipleOf")
    }
}

public struct Metadata: ImmutableMappable {

    /// The data type of the schema.
    public let type: DataType

    /// A short description of the schema.
    public let title: String?

    /// A more lengthy explanation about the purpose of the data described by the schema
    public let description: String?

    /// Used to specify the default value for the parent schema.
    public let defaultValue: Any?

    /// Used to restrict the schema to a specific set of values.
    public let enumeratedValues: [Any?]?

    public init(map: Map) throws {
        // Not a reference, determine the type
        if let typeString: String = try? map.value("type"), let mappedType = DataType(rawValue: typeString) {
            type = mappedType
        } else if map.JSON["items"] != nil {
            // Implicit array
            type = .array
        } else if map.JSON["properties"] != nil {
            // Implicit object
            type = .object
        } else if map.JSON["enum"] != nil {
            type = .enumeration
        } else {
            throw DecodingError()
        }

        title = try? map.value("title")
        description = try? map.value("description")
        defaultValue = try? map.value("default")
        enumeratedValues = try? map.value("enum")
    }
}
