import Foundation
import ObjectMapper

/// Allows referencing an external resource for extended documentation.
public struct ExternalDocumentation {

    /// The URL for the target documentation.
    let url: URL

    /// A short description of the target documentation. 
    /// GFM syntax can be used for rich text representation.
    let description: String?
}

struct ExternalDocumentationBuilder: Builder {

    typealias Building = ExternalDocumentation

    let url: URL
    let description: String?

    init(map: Map) throws {
        url = try map.value("url", using: URLTransform())
        description = try? map.value("description")
    }

    func build(_ swagger: SwaggerBuilder) throws -> ExternalDocumentation {
        return ExternalDocumentation(url: self.url, description: self.description)
    }
}
