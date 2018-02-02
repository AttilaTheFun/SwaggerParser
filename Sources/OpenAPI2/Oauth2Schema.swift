import Foundation
import OpenAPI

public struct OAuth2Schema {
    public let flow: OAuth2Flow
    public let authorizationURL: URL?
    public let tokenURL: URL?
    public let scopes: [String: String]
}

struct OAuth2SchemaBuilder: Codable {
    let flow: OAuth2Flow
    let authorizationURL: URL?
    let tokenURL: URL?
    let scopes: [String: String]

    enum CodingKeys: String, CodingKey {
        case flow
        case authorizationURL = "authorizationUrl"
        case tokenURL = "tokenUrl"
        case scopes
    }
}

extension OAuth2SchemaBuilder: Builder {
    typealias Building = OAuth2Schema

    func build(_ swagger: SwaggerBuilder) throws -> OAuth2Schema {
        return OAuth2Schema(
            flow: self.flow,
            authorizationURL: self.authorizationURL,
            tokenURL: self.tokenURL,
            scopes: self.scopes)
    }
}
