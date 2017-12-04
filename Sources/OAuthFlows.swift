
public struct OAuth2Flows {
    
    /// Configuration for the OAuth Implicit flow
    public let implicit: OAuth2Schema?
    
    /// Configuration for the OAuth Resource Owner Password flow
    public let password: OAuth2Schema?
    
    /// Configuration for the OAuth Client Credentials flow.
    /// Previously called application in OpenAPI 2.0.
    public let clientCredentials: OAuth2Schema?
    
    /// Configuration for the OAuth Authorization Code flow.
    /// Previously called accessCode in OpenAPI 2.0.
    public let authorizationCode: OAuth2Schema?
}

struct OAuth2FlowsBuilder: Codable {
    let implicit: OAuth2SchemaBuilder?
    let password: OAuth2SchemaBuilder?
    let clientCredentials: OAuth2SchemaBuilder?
    let authorizationCode: OAuth2SchemaBuilder?
    
    enum CodingKeys: String, CodingKey {
        case implicit
        case password
        case clientCredentials
        case authorizationCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.implicit = try values.decodeIfPresent(OAuth2SchemaBuilder.self, forKey: .implicit)
        self.password = try values.decodeIfPresent(OAuth2SchemaBuilder.self, forKey: .password)
        self.clientCredentials = try values.decodeIfPresent(OAuth2SchemaBuilder.self, forKey: .clientCredentials)
        self.authorizationCode = try values.decodeIfPresent(OAuth2SchemaBuilder.self, forKey: .authorizationCode)
    }
}

extension OAuth2FlowsBuilder: Builder {
    typealias Building = OAuth2Flows
    
    func build(_ swagger: SwaggerBuilder) throws -> OAuth2Flows {
        return OAuth2Flows(implicit: try implicit?.build(swagger),
                           password: try password?.build(swagger),
                           clientCredentials: try clientCredentials?.build(swagger),
                           authorizationCode: try authorizationCode?.build(swagger))
    }
}
