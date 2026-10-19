
public struct APIKeySchema: Equatable, Hashable {
    public let headerName: String
    public let keyLocation: APIKeyLocation
}

struct APIKeySchemaBuilder: Codable {
    let headerName: String
    let keyLocation: APIKeyLocation

    enum CodingKeys: String, CodingKey {
        case headerName = "name"
        case keyLocation = "in"
    }
}

extension APIKeySchemaBuilder: Builder {

    typealias Building = APIKeySchema

    func build(_ swagger: SwaggerBuilder) throws -> APIKeySchema {
        return APIKeySchema(headerName: self.headerName, keyLocation: self.keyLocation)
    }
}
