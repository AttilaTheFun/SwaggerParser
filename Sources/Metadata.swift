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
}

struct MetadataBuilder: Builder {

    typealias Building = Metadata
    let type: DataType
    let title: String?
    let description: String?
    let defaultValue: Any?
    let enumeratedValues: [Any?]?

    init(map: Map) throws {
        if let typeString: String = try? map.value("type"), let mappedType = DataType(rawValue: typeString) {
            type = mappedType
        } else if map.JSON["items"] != nil {
            // Implicit array
            type = .array
        } else if map.JSON["properties"] != nil || map.JSON["allOf"] != nil {
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

    func build(_ swagger: SwaggerBuilder) throws -> Metadata {
        return Metadata(type: self.type, title: self.title, description: self.description,
                        defaultValue: self.defaultValue, enumeratedValues: self.enumeratedValues)
    }

    var hasFieldsOtherThanType: Bool {
        return self.title != nil || self.description != nil || self.defaultValue != nil ||
            self.enumeratedValues != nil
    }
}

extension MetadataBuilder: Equatable {
    static func ==(lhs: MetadataBuilder, rhs: MetadataBuilder) -> Bool {
        return lhs.type == rhs.type && lhs.title == rhs.title && lhs.description == rhs.description &&
            isEqual(lhs: lhs.defaultValue, rhs: rhs.defaultValue) &&
            isEqual(lhs: lhs.enumeratedValues, rhs: rhs.enumeratedValues)
    }
}

private func isEqual(lhs: Any?, rhs: Any?) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.some, .none), (.none, .some):
        return false
    case (.some(let lhs), .some(let rhs)):
        switch (lhs, rhs) {
        case (let v1 as Double, let v2 as Double):
            return v1 == v2
        case (let v1 as Int, let v2 as Int):
            return v1 == v2
        case (let v1 as String, let v2 as String):
            return v1 == v2
        case (let v1 as [Any?], let v2 as [Any?]):
            if v1.count != v2.count {
                return false
            }

            for (index, value) in v1.enumerated() {
                if !isEqual(lhs: value, rhs: v2[index]) {
                    return false
                }
            }

            return true
        default:
            return false
        }
    }
}
