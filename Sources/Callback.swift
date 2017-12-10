/// A map of possible out-of band callbacks related to the parent operation.
///
/// Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
public typealias Callback = [String: Path]

struct CallbackBuilder: Codable {
    let callbacks: [String: PathBuilder]
    
    init(from decoder: Decoder) throws {
        self.callbacks = try [String: PathBuilder](from: decoder)
    }
}

extension CallbackBuilder: Builder {
    typealias Building = Callback
    
    func build(_ swagger: SwaggerBuilder) throws -> Callback {
        return try callbacks.mapValues { try $0.build(swagger) }
    }
}

extension CallbackBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<CallbackBuilder>) throws
        -> Either<Callback, Structure<Callback>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
