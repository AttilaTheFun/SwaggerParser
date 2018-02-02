import OpenAPI

public struct ServerVariable {
    
    /// The default value to use for substitution, and to send, if an alternate value is not supplied.
    public let defaults: String
    
    /// An enumeration of string values to be used if the substitution options are from a limited set.
    public let enumeration: [String]?
    
    /// An optional description for the server variable.
    public let description: String?
}

struct ServerVariableBuilder: Codable {
    let defaults: String
    let enumeration: [String]?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case defaults = "default"
        case enumeration = "enum"
        case description
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.defaults = try values.decode(String.self, forKey: .defaults)
        self.enumeration = try values.decodeIfPresent([String].self, forKey: .enumeration)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
    }
}

extension ServerVariableBuilder: Builder {
    typealias Building = ServerVariable
    
    func build(_ swagger: SwaggerBuilder) throws -> ServerVariable {
        return ServerVariable(defaults: self.defaults,
                              enumeration: self.enumeration,
                              description: self.description)
    }
}
