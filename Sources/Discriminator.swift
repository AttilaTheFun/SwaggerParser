
public struct Discriminator {
    
    /// REQUIRED. The name of the property in the payload that will hold the discriminator value.
    public let propertyName: String
    
    /// An object to hold mappings between payload values and schema names or references.
    public let mapping: [String: String]
    
}

struct DiscriminatorBuilder: Codable {
    let propertyName: String
    let mapping: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case propertyName
        case mapping
    }
}

extension DiscriminatorBuilder: Builder {
    typealias Building = Discriminator
    
    func build(_ swagger: SwaggerBuilder) throws -> Discriminator {
        return Discriminator(propertyName: self.propertyName, mapping: self.mapping)
    }
}
