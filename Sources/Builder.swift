
protocol Builder: Codable {
    associatedtype Building

    func build(_ swagger: SwaggerBuilder) throws -> Building
}
