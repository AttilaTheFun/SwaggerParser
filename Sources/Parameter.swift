import ObjectMapper

public enum ParameterLocation: String {
    case query = "query"
    case header = "header"
    case path = "path"
    case formData = "formData"
    case body = "body"
}

public struct FixedParameterFields: ImmutableMappable {
    /// The name of the parameter. Parameter names are case sensitive.
    /// If in is "path", the name field MUST correspond to the associated path segment from the path 
    /// field in the Paths Object.
    public let name: String

    /// The location of the parameter.
    public let location: ParameterLocation

    /// A brief description of the parameter. This could contain examples of use.
    public let description: String?

    /// Determines whether this parameter is mandatory. If the parameter is in "path", this property is 
    /// required and its value MUST be true. Its default value is false.
    public let required: Bool

    public init(map: Map) throws {
        name = try map.value("name")
        location = try map.value("in")
        description = try? map.value("description")
        required = (try? map.value("required")) ?? false
    }
}

/// Describes a single operation parameter. Parameters can be passed in:
/// Path, Query, Header, Body, Form
public enum Parameter: ImmutableMappable {
    case body(fixedFields: FixedParameterFields, schema: Schema)
    // TODO: Handle files & allow empty value.
    case other(fixedFields: FixedParameterFields, items: Items)

    public init(map: Map) throws {
        let fixedFields = try FixedParameterFields(map: map)
        switch fixedFields.location {
        case .body:
            self = .body(fixedFields: fixedFields, schema: try map.value("schema"))
        case .query, .header, .path, .formData:
            self = .other(fixedFields: fixedFields, items: try Items(map: map))
        }
    }
}
