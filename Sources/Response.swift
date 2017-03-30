import ObjectMapper

public struct Response: ImmutableMappable {

    /// A short description of the response. GFM syntax can be used for rich text representation.
    public let description: String

    /// A definition of the response structure. It can be a primitive, an array or an object. 
    /// If this field does not exist, it means no content is returned as part of the response.
    public let schema: Schema?

    /// Lists the headers that can be sent as part of a response.
    /// The name of the property corresponds to the name of the header. 
    /// The value describes the type of the header.
    public let headers: [String : Header]?

    public init(map: Map) throws {
        description = try map.value("description")
        schema = try? map.value("schema")
        headers = try? map.value("headers")
    }
}
