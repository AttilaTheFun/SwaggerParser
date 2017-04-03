import Foundation
import ObjectMapper

public enum OAuth2FlowType: String {
    case implicit = "implicit"
    case password = "password"
    case application = "application"
    case accessCode = "accessCode"
}

public struct OAuth2Schema {
    public let type: OAuth2FlowType
    public let authorizationURL: URL?
    public let tokenURL: URL?
    public let scopes: [String : String]
}

struct OAuth2SchemaBuilder: Builder {

    typealias Building = OAuth2Schema

    let type: OAuth2FlowType
    let authorizationURL: URL?
    let tokenURL: URL?
    let scopes: [String : String]

    init(map: Map) throws {
        type = try map.value("flow")
        authorizationURL = try? map.value("authorizationUrl")
        tokenURL = try? map.value("tokenUrl")
        scopes = try map.value("scopes")
    }

    func build(_ swagger: SwaggerBuilder) throws -> OAuth2Schema {
        return OAuth2Schema(type: self.type, authorizationURL: self.authorizationURL, tokenURL: self.tokenURL,
                            scopes: self.scopes)
    }
}
