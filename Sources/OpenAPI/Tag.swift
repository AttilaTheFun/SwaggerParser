
/// Allows adding meta data to a single tag that is used by the Operation.
/// It is not mandatory to have a Tag per tag used there.
public struct Tag {

    /// The name of the tag.
    let name: String

    /// A short description for the tag. 
    /// GFM syntax can be used for rich text representation.
    let description: String?

    /// Additional external documentation for this tag.
    let externalDocumentation: ExternalDocumentation?
}

public struct TagBuilder: Codable {
    let name: String
    let description: String?
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case externalDocumentationBuilder = "externalDocs"
    }
}

extension TagBuilder: Builder {
    public typealias Building = Tag

    public func build(_ swagger: SwaggerBuilder) throws -> Tag {
        return Tag(name: self.name, description: self.description,
                   externalDocumentation: try self.externalDocumentationBuilder?.build(swagger))
    }
}
