import Foundation
import OpenAPI

public struct RequestBody {
    
    /// A brief description of the request body.
    ///
    /// This could contain examples of use.
    /// CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// REQUIRED. The content of the request body.
    ///
    /// The key is a media type or media type range and the value describes it.
    /// For requests that match multiple keys, only the most specific key is applicable.
    public let content: [String: MediaType]
    
    /// Determines if the request body is required in the request. Defaults to false.
    public let required: Bool
    
}

struct RequestBodyBuilder: Codable {
    let description: String?
    let content: [String: MediaTypeBuilder]
    let required: Bool
    
    enum CodingKeys: String, CodingKey {
        case description
        case content
        case required
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.content = try values.decode([String: MediaTypeBuilder].self, forKey: .content)
        self.required = try values.decodeIfPresent(Bool.self, forKey: .required) ?? false
    }
}

extension RequestBodyBuilder: Builder {
    typealias Building = RequestBody
    
    func build(_ swagger: SwaggerBuilder) throws -> RequestBody {
        let content = try self.content.mapValues { try $0.build(swagger) }
        return RequestBody(description: self.description,
                           content: content,
                           required: self.required)
    }
}

extension RequestBodyBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<RequestBodyBuilder>) throws
        -> Either<RequestBody, Structure<RequestBody>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
