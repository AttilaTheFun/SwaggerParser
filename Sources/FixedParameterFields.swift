
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
    
    /// An example value for the parameter.
    public let example: Any?
}

struct FixedParameterFieldsBuilder: Codable {
    let name: String
    let location: ParameterLocation
    let description: String?
    let required: Bool
    let example: String?

    enum CodingKeys: String, CodingKey {
        case name
        case location = "in"
        case description
        case required
        case example = "x-example"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.location = try values.decode(ParameterLocation.self, forKey: .location)
        self.description = try? values.decode(String.self, forKey: .description)
        self.required = (try values.decodeIfPresent(Bool.self, forKey: .required)) ?? false
        self.example = try? values.decode(String.self, forKey: .example)
        // TODO: Decode example as any.
    }
}

extension FixedParameterFieldsBuilder: Builder {
    typealias Building = FixedParameterFields

    func build(_ swagger: SwaggerBuilder) throws -> FixedParameterFields {
        return FixedParameterFields(name: self.name, location: self.location, description: self.description,
                                    required: self.required, example: self.example)
    }
}
