
public protocol Builder: Codable {
    associatedtype Building

    func build(_ swagger: SwaggerBuilder) throws -> Building
}

public protocol SwaggerBuilder {
    func resolveBuilderName(from components: [String], at path: String) throws -> String
    func resolveBuilder(for name: String, at path: String) throws -> Any?
}
