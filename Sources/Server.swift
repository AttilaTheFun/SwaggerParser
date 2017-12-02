import Foundation

public struct Server {
    
    /// A URL to the target host.
    ///
    /// This URL supports Server Variables and MAY be relative,
    /// to indicate that the host location is relative to the location
    /// where the OpenAPI document is being served.
    ///
    /// Variable substitutions will be made when a variable is named in {brackets}
    public let url: String
    
    /// An optional string describing the host designated by the URL.
    public let description: String?
    
    /// A map between a variable name and its value.
    ///
    /// The value is used for substitution in the server's URL template.
    public let variables: [String: ServerVariable]?
}

struct ServerBuilder: Codable {
    let url: String
    let description: String?
    let variables: [String: ServerVariableBuilder]?
    
    enum CodingKeys: String, CodingKey {
        case url
        case description
        case variables
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try values.decode(String.self, forKey: .url)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.variables = try values.decodeIfPresent([String: ServerVariableBuilder].self, forKey: .variables)
    }
}

extension ServerBuilder: Builder {
    typealias Building = Server
    
    func build(_ swagger: SwaggerBuilder) throws -> Server {
        let variables = self.variables?.mapValues({ try! $0.build(swagger) })
        return Server(url: self.url,
                      description: self.description,
                      variables: variables)
    }
}
