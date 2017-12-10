/// The Link object represents a possible design-time link for a response.
/// The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.
public struct Link {
    
    /// A relative or absolute reference to an OAS operation.
    ///
    /// This field is mutually exclusive of the operationId field, and MUST point to an Operation Object. Relative operationRef values MAY be used to locate an existing Operation Object in the OpenAPI definition.
    public let operationRef: String?
    
    /// The name of an existing, resolvable OAS operation, as defined with a unique operationId.
    /// This field is mutually exclusive of the operationRef field.
    public let operationId: String?
    
    /// A map representing parameters to pass to an operation as specified with operationId or identified via operationRef. The key is the parameter name to be used, whereas the value can be a constant or an expression to be evaluated and passed to the linked operation. The parameter name can be qualified using the parameter location [{in}.]{name} for operations that use the same parameter name in different locations (e.g. path.id).
    public let parameters: [String: Any]
    
    /// A literal value or {expression} to use as a request body when calling the target operation.
    public let requestBody: Any? // TODO: possibly add RuntimeExpression for {expression}
    
    /// A description of the link.
    /// CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// A server object to be used by the target operation.
    public let server: Server?
}

struct LinkBuilder: Codable {
    let operationRef: String?
    let operationId: String?
    let parameters: [String: String]
    let requestBody: String?
    let description: String?
    let server: ServerBuilder?
    
    enum CodingKeys: String, CodingKey {
        case operationRef
        case operationId
        case parameters
        case requestBody
        case description
        case server
    }
}

extension LinkBuilder: Builder {
    typealias Building = Link
    
    func build(_ swagger: SwaggerBuilder) throws -> Link {
        return Link(operationRef: self.operationRef,
                    operationId: self.operationId,
                    parameters: self.parameters,
                    requestBody: self.requestBody,
                    description: self.description,
                    server: try self.server?.build(swagger))
    }
}

extension LinkBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<LinkBuilder>) throws
        -> Either<Link, Structure<Link>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}

