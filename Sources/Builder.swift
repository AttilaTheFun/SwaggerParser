import ObjectMapper

protocol Builder: ImmutableMappable {
    associatedtype Building
    func build(_ swagger: SwaggerBuilder) throws -> Building
}
