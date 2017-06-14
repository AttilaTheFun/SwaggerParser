import ObjectMapper

public struct Metadata {

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
    
    /// Whether or not the schema can be nil. Corresponds to `x-nullable`.
    public let nullable: Bool
    
    /// An example value for the schema.
    public let example: Any?
}

struct MetadataBuilder: Builder {

    typealias Building = Metadata
    let type: DataType
    let title: String?
    let description: String?
    let defaultValue: Any?
    let enumeratedValues: [Any?]?
    let nullable: Bool
    let example: Any?

    init(map: Map) throws {
        if map.JSON["$ref"] != nil {
            type = .reference
        } else if let typeString: String = try? map.value("type"), let mappedType = DataType(rawValue: typeString) {
            type = mappedType
        } else if map.JSON["items"] != nil {
            // Implicit array
            type = .array
        } else if map.JSON["properties"] != nil {
            // Implicit object
            type = .object
        } else if map.JSON["enum"] != nil {
            type = .enumeration
        } else if map.JSON["allOf"] != nil {
            type = .allOf
        } else {
            throw DecodingError()
        }

        title = try? map.value("title")
        description = try? map.value("description")
        defaultValue = try? map.value("default")
        enumeratedValues = try? map.value("enum")
        nullable = (try? map.value("x-nullable")) ?? false
        example = try? map.value("example")
    }
    
    func build(_ swagger: SwaggerBuilder) throws -> Metadata {
        return Metadata(type: self.type, title: self.title, description: self.description,
                        defaultValue: self.defaultValue, enumeratedValues: self.enumeratedValues,
                        nullable: self.nullable, example: self.example)
    }
}
