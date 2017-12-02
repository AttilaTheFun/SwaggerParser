
public struct Parameter {
    
    /// REQUIRED. The name of the parameter. Parameter names are case sensitive.
    ///
    /// If in is "path", the name field MUST correspond to the associated path segment from the path field in the Paths Object. See Path Templating for further information.
    ///
    /// If in is "header" and the name field is "Accept", "Content-Type" or "Authorization", the parameter definition SHALL be ignored.
    ///
    /// For all other cases, the name corresponds to the parameter name used by the in property.
    public let name: String
    
    /// REQUIRED. The location of the parameter.
    /// Possible values are "query", "header", "path" or "cookie".
    public let location: ParameterLocation
    
    /// A brief description of the parameter.
    /// This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// Determines whether this parameter is mandatory.
    /// If the parameter location is "path", this property is REQUIRED and its value MUST be true.
    /// Otherwise, the property MAY be included and its default value is false.
    public let required: Bool?
    
    /// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage.
    public let deprecated: Bool?

    /// Sets the ability to pass empty-valued parameters.
    /// This is valid only for query parameters and allows sending a parameter with an empty value.
    /// Default value is false. If style is used, and if behavior is n/a (cannot be serialized), the value of allowEmptyValue SHALL be ignored.
    public let allowEmptyValue: Bool?
    
    public let schema: Either<Schema, Structure<Schema>>?

}

struct ParameterBuilder: Codable {
    
    let name: String
    let location: ParameterLocation
    let description: String?
    let required: Bool?
    let deprecated: Bool?
    let allowEmptyValue: Bool?
    let schema: Reference<SchemaBuilder>?

    enum CodingKeys: String, CodingKey {
        case name
        case location = "in"
        case description
        case required
        case deprecated
        case allowEmptyValue
        case schema
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.location = try values.decode(ParameterLocation.self, forKey: .location)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.required = try values.decodeIfPresent(Bool.self, forKey: .required)
        self.deprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated)
        self.allowEmptyValue = try values.decodeIfPresent(Bool.self, forKey: .allowEmptyValue)
        self.schema = try values.decodeIfPresent(Reference<SchemaBuilder>.self, forKey: .schema)
    }
}

extension ParameterBuilder: Builder {
    typealias Building = Parameter
    
    func build(_ swagger: SwaggerBuilder) throws -> Parameter {
        let schema = try SchemaBuilder.resolve(swagger, reference: self.schema!)
        return Parameter(name: self.name,
                         location: self.location,
                         description: self.description,
                         required: self.required,
                         deprecated: self.deprecated,
                         allowEmptyValue: self.allowEmptyValue,
                         schema: schema)
    }
}


extension ParameterBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<ParameterBuilder>) throws
        -> Either<Parameter, Structure<Parameter>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
