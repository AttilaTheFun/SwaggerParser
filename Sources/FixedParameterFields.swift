import ObjectMapper

public enum ParameterLocation: String {
    case query = "query"
    case header = "header"
    case path = "path"
    case formData = "formData"
    case body = "body"
}

public struct FixedParameterFields {
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
}

struct FixedParameterFieldsBuilder: Builder {

    typealias Building = FixedParameterFields
    let name: String
    let location: ParameterLocation
    let description: String?
    let required: Bool

    init(map: Map) throws {
        name = try map.value("name")
        location = try map.value("in")
        description = try? map.value("description")
        required = (try? map.value("required")) ?? false
    }

    func build(_ swagger: SwaggerBuilder) throws -> FixedParameterFields {
        return FixedParameterFields(name: self.name, location: self.location, description: self.description,
                                    required: self.required)
    }
}
