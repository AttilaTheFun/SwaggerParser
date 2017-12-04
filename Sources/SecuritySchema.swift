
public typealias SecurityRequirement = [String: [String]]

public enum SecuritySchema {
    case basic(description: String?)
    case apiKey(description: String?, schema: APIKeySchema)
    case oauth2(description: String?, schema: OAuth2Flows)
    // TODO: openIdConnect
}

enum SecuritySchemaBuilder: Codable {
    case basic(description: String?)
    case apiKey(description: String?, schema: APIKeySchemaBuilder)
    case oauth2(description: String?, schema: OAuth2FlowsBuilder)

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case flows
    }

    init(from decoder: Decoder) throws {
        enum SecurityType: String, Codable {
            case basic = "http"
            case apiKey
            case oauth2
            // TODO: case openIdConnect
        }

        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(SecurityType.self, forKey: .type)
        let description = try values.decodeIfPresent(String.self, forKey: .description)
        switch type {
        case .basic:
            self = .basic(description: description)
        case .apiKey:
            self = .apiKey(description: description, schema: try APIKeySchemaBuilder(from: decoder))
        case .oauth2:
            let flows = try values.decode(OAuth2FlowsBuilder.self, forKey: .flows)
            self = .oauth2(description: description, schema: flows)
        }
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        let description: String?
        switch self {
        case .basic(let basicDescription):
            description = basicDescription
        case .apiKey(let apiKeyDescription, let schema):
            description = apiKeyDescription
            try schema.encode(to: encoder)
        case .oauth2(let oauth2Description, let schema):
            description = oauth2Description
            try schema.encode(to: encoder)
        }

        if let description = description {
            try values.encode(description, forKey: .description)
        }
    }
}

extension SecuritySchemaBuilder: Builder {
    typealias Building = SecuritySchema

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

extension SecuritySchemaBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<SecuritySchemaBuilder>) throws
        -> Either<SecuritySchema, Structure<SecuritySchema>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}

