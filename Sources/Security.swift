import Foundation
import ObjectMapper

public enum OAuth2FlowType: String {
    case implicit = "implicit"
    case password = "password"
    case application = "application"
    case accessCode = "accessCode"
}

public struct OAuth2Schema: ImmutableMappable {
    public let type: OAuth2FlowType
    public let authorizationURL: URL?
    public let tokenURL: URL?
    public let scopes: [String : String]

    public init(map: Map) throws {
        type = try map.value("flow")
        authorizationURL = try? map.value("authorizationUrl")
        tokenURL = try? map.value("tokenUrl")
        scopes = try map.value("scopes")
    }
}

private enum SecurityType: String {
    case basic = "basic"
    case apiKey = "apiKey"
    case oauth2 = "oauth2"
}

public enum APIKeyLocation: String {
    case query = "query"
    case header = "header"
}

public struct APIKeySchema: ImmutableMappable {
    public let headerName: String
    public let keyLocation: APIKeyLocation

    public init(map: Map) throws {
        headerName = try map.value("name")
        keyLocation = try map.value("in")
    }
}

public enum SecuritySchema: ImmutableMappable {
    case basic(description: String?)
    case apiKey(description: String?, schema: APIKeySchema)
    case oauth2(description: String?, schema: OAuth2Schema)

    public init(map: Map) throws {
        let securityType: SecurityType = try map.value("type")
        let description: String? = try? map.value("description")
        switch securityType {
        case .basic:
            self = .basic(description: description)
        case .apiKey:
            self = .apiKey(description: description, schema: try APIKeySchema(map: map))
        case .oauth2:
            self = .oauth2(description: description, schema: try OAuth2Schema(map: map))
        }
    }
}
