
public struct APIKeySchema {
    public let headerName: String
    public let keyLocation: APIKeyLocation
}

public struct APIKeySchemaBuilder: Codable {
    let headerName: String
    let keyLocation: APIKeyLocation

    enum CodingKeys: String, CodingKey {
        case headerName = "name"
        case keyLocation = "in"
    }
}

extension APIKeySchemaBuilder: Builder {

    public typealias Building = APIKeySchema

    public func build(_ swagger: SwaggerBuilder) throws -> APIKeySchema {
        return APIKeySchema(headerName: self.headerName, keyLocation: self.keyLocation)
    }
}
