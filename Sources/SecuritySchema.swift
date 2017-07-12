import ObjectMapper

private enum SecurityType: String {
    case basic = "basic"
    case apiKey = "apiKey"
    case oauth2 = "oauth2"
}

public enum SecuritySchema {
    case basic(description: String?)
    case apiKey(description: String?, schema: APIKeySchema)
    case oauth2(description: String?, schema: OAuth2Schema)
}

enum SecuritySchemaBuilder: Builder {

    typealias Building = SecuritySchema

    case basic(description: String?)
    case apiKey(description: String?, schema: APIKeySchemaBuilder)
    case oauth2(description: String?, schema: OAuth2SchemaBuilder)

    init(map: Map) throws {
        let securityType: SecurityType = try map.value("type")
        let description: String? = try? map.value("description")
        switch securityType {
        case .basic:
            self = .basic(description: description)
        case .apiKey:
            self = .apiKey(description: description, schema: try APIKeySchemaBuilder(map: map))
        case .oauth2:
            self = .oauth2(description: description, schema: try OAuth2SchemaBuilder(map: map))
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> SecuritySchema {
        switch self {
        case .basic(let description):
            return .basic(description: description)
        case .apiKey(let description, let builder):
            return .apiKey(description: description, schema: try builder.build(swagger))
        case .oauth2(let description, let builder):
            return .oauth2(description: description, schema: try builder.build(swagger))
        }
    }
}
