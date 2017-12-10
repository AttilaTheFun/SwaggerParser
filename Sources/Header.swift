/// The Header Object follows the structure of the Parameter Object with the following changes:
/// - 'name' MUST NOT be specified, it is given in the corresponding headers map.
/// - 'in' MUST NOT be specified, it is implicitly in header.
/// All traits that are affected by the location MUST be applicable to a location of header (for example, style).

public typealias Header = ParameterDefinition
typealias HeaderBuilder = ParameterDefinitionBuilder

extension HeaderBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<HeaderBuilder>) throws
        -> Either<Header, Structure<Header>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
