import ObjectMapper

public struct APIKeySchema {
    public let headerName: String
    public let keyLocation: APIKeyLocation
}

struct APIKeySchemaBuilder: Builder {

    typealias Building = APIKeySchema

    let headerName: String
    let keyLocation: APIKeyLocation

    init(map: Map) throws {
        headerName = try map.value("name")
        keyLocation = try map.value("in")
    }

    func build(_ swagger: SwaggerBuilder) throws -> APIKeySchema {
        return APIKeySchema(headerName: self.headerName, keyLocation: self.keyLocation)
    }
}
