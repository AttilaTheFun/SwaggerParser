import ObjectMapper

public struct Response {

    /// A short description of the response. GFM syntax can be used for rich text representation.
    public let description: String

    /// A definition of the response structure. It can be a primitive, an array or an object. 
    /// If this field does not exist, it means no content is returned as part of the response.
    public let schema: Schema?

    /// Lists the headers that can be sent as part of a response.
    /// The name of the property corresponds to the name of the header. 
    /// The value describes the type of the header.
    public let headers: [String : Items]
}

struct ResponseBuilder: Builder {

    typealias Building = Response

    let description: String
    let schema: SchemaBuilder?
    let headers: [String : ItemsBuilder]

    init(map: Map) throws {
        description = try map.value("description")
        schema = try? map.value("schema")
        headers = (try? map.value("headers")) ?? [:]
    }

    func build(_ swagger: SwaggerBuilder) throws -> Response {
        let headers = try Dictionary(self.headers.map { ($0, try $1.build(swagger)) })
        return Response(description: self.description, schema: try self.schema?.build(swagger),
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
