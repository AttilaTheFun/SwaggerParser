
public struct Response {

    /// A short description of the response. GFM syntax can be used for rich text representation.
    public let description: String

    /// A definition of the response structure. It can be a primitive, an array or an object. 
    /// If this field does not exist, it means no content is returned as part of the response.
    public let schema: Schema?

    /// Lists the headers that can be sent as part of a response.
    /// The name of the property corresponds to the name of the header. 
    /// The value describes the type of the header.
    public let headers: [String: Items]
}

struct ResponseBuilder: Codable {
    let description: String
    let schemaBuilder: SchemaBuilder?
    let headerBuilders: [String: ItemsBuilder]

    enum CodingKeys: String, CodingKey {
        case description
        case schemaBuilder = "schema"
        case headerBuilders = "headers"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try values.decode(String.self, forKey: .description)
        self.schemaBuilder = try values.decodeIfPresent(SchemaBuilder.self, forKey: .schemaBuilder)
        self.headerBuilders = try values.decodeIfPresent([String : ItemsBuilder].self,
                                                         forKey: .headerBuilders) ?? [:]
    }
}

extension ResponseBuilder: Builder {
    typealias Building = Response

    func build(_ swagger: SwaggerBuilder) throws -> Response {
        let headers = try self.headerBuilders.mapValues { try $0.build(swagger) }
        return Response(description: self.description,
                        schema: try self.schemaBuilder?.build(swagger),
                        headers: headers)
    }
}

extension ResponseBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<ResponseBuilder>) throws ->
        Either<Response, Structure<Response>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
