import Foundation

public struct OAuth2Schema {
    public let authorizationURL: URL?
    public let tokenURL: URL?
    public let refreshURL: URL?
    public let scopes: [String: String]
}

struct OAuth2SchemaBuilder: Codable {
    let authorizationURL: URL?
    let tokenURL: URL?
    let refreshURL: URL?
    let scopes: [String: String]

    enum CodingKeys: String, CodingKey {
        case authorizationURL = "authorizationUrl"
        case tokenURL = "tokenUrl"
        case refreshURL = "refreshUrl"
        case scopes
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.authorizationURL = try values.decodeIfPresent(URL.self, forKey: .authorizationURL)
        self.tokenURL = try values.decodeIfPresent(URL.self, forKey: .tokenURL)
        self.refreshURL = try values.decodeIfPresent(URL.self, forKey: .refreshURL)
        self.scopes = try values.decodeIfPresent([String: String].self, forKey: .scopes) ?? [:]
    }
}

extension OAuth2SchemaBuilder: Builder {
    typealias Building = OAuth2Schema

    func build(_ swagger: SwaggerBuilder) throws -> OAuth2Schema {
        return OAuth2Schema(authorizationURL: self.authorizationURL,
                            tokenURL: self.tokenURL,
                            refreshURL: self.refreshURL,
                            scopes: self.scopes)
    }
}
