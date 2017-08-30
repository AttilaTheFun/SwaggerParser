import Foundation

/// Allows referencing an external resource for extended documentation.
public struct ExternalDocumentation {

    /// The URL for the target documentation.
    let url: URL

    /// A short description of the target documentation. 
    /// GFM syntax can be used for rich text representation.
    let description: String?
}

struct ExternalDocumentationBuilder: Codable {
    let url: URL
    let description: String?
}

extension ExternalDocumentationBuilder: Builder {
    typealias Building = ExternalDocumentation

    func build(_ swagger: SwaggerBuilder) throws -> ExternalDocumentation {
        return ExternalDocumentation(url: self.url, description: self.description)
    }
}
