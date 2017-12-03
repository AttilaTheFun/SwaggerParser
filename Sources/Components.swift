
public struct Components {
    
    /// An object to hold reusable Schema Objects.
    public let schemas: [String: Either<Schema, Structure<Schema>>]
}

struct ComponentsBuilder: Codable {
    let schemas: [String: Reference<SchemaBuilder>]
    
    enum CodingKeys: String, CodingKey {
        case schemas
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.schemas = try values.decodeIfPresent([String: Reference<SchemaBuilder>].self,
                                                  forKey: .schemas) ?? [:]
    }
}

extension ComponentsBuilder: Builder {
    typealias Building = Components
    
    func build(_ swagger: SwaggerBuilder) throws -> Components {
        let schemas = try self.schemas.mapValues {
            try SchemaBuilder.resolve(swagger, reference: $0)
        }
        return Components(schemas: schemas)
    }
}
