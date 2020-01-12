import OpenAPI
import Foundation

/// OpenAPI 3 Encoding Object
///
/// A single encoding definition applied to a single schema property.
public struct Encoding {

    /// The Content-Type for encoding a specific property.
    ///
    /// Default value depends on the property type: for string with format being binary – application/octet-stream; for other primitive types – text/plain; for object - application/json; for array – the default is defined based on the inner type. The value can be a specific media type (e.g. application/json), a wildcard media type (e.g. image/ *), or a comma-separated list of the two types.
    public let contentType: String

    /// A map allowing additional information to be provided as headers, for example Content-Disposition. Content-Type is described separately and SHALL be ignored in this section. This property SHALL be ignored if the request body media type is not a multipart.
    public let headers: [String: Either<Header, Structure<Header>>]
    
    /// Describes how a specific property value will be serialized depending on its type. See Parameter Object for details on the style property. The behavior follows the same values as query parameters, including default values. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
    public let style: SerializationStyle?

    /// When this is true, property values of type array or object generate separate parameters for each value of the array, or key-value-pair of the map. For other types of properties this property has no effect. When style is form, the default value is true. For all other styles, the default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
    public let explode: Bool
    
    /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. The default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
    public let allowReserved: Bool
 
}

struct EncodingBuilder: Codable {
    let contentType: String?
    let headers: [String: Reference<HeaderBuilder>]
    let style: SerializationStyle?
    let explode: Bool?
    let allowReserved: Bool?

    enum CodingKeys: String, CodingKey {
        case contentType
        case headers
        case style
        case explode
        case allowReserved
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.contentType = try values.decode(String.self, forKey: .contentType)
        self.style = try values.decodeIfPresent(SerializationStyle.self, forKey: .style)
        self.explode = try values.decodeIfPresent(Bool.self, forKey: .explode)
        self.allowReserved = try values.decodeIfPresent(Bool.self, forKey: .allowReserved)
        self.headers = try values.decodeIfPresent([String: Reference<HeaderBuilder>].self, forKey: .headers) ?? [:]
    }
}

extension EncodingBuilder: Builder {
    typealias Building = Encoding
    
    func build(_ swagger: SwaggerBuilder) throws -> Encoding {
        let contentType = self.contentType ?? "" // TODO: Default values
        let headers = try self.headers.mapValues { try HeaderBuilder.resolve(swagger, reference: $0) }
        return Encoding(contentType: contentType,
                        headers: headers,
                        style: self.style,
                        explode: self.explode ?? false, // TODO: default depends on style
                        allowReserved: self.allowReserved ?? false)
    }
}
