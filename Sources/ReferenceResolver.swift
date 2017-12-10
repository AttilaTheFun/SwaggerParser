
protocol ResolvableType: Builder {
    static var path: String { get }
}

private let kSchemaBuilderReferenceResolver = ReferenceResolver<SchemaBuilder>()
extension SchemaBuilder: ResolvableType {
    static var path: String { return "schemas" }
    static var resolver: ReferenceResolver<SchemaBuilder> { return kSchemaBuilderReferenceResolver }
}

private let kParameterBuilderReferenceResolver = ReferenceResolver<ParameterBuilder>()
extension ParameterBuilder: ResolvableType {
    static var path: String { return "parameters" }
    static var resolver: ReferenceResolver<ParameterBuilder> { return kParameterBuilderReferenceResolver }
}

private let kResponseBuilderReferenceResolver = ReferenceResolver<ResponseBuilder>()
extension ResponseBuilder: ResolvableType {
    static var path: String { return "responses" }
    static var resolver: ReferenceResolver<ResponseBuilder> { return kResponseBuilderReferenceResolver }
}

private let kSecuritySchemaBuilderReferenceResolver = ReferenceResolver<SecuritySchemaBuilder>()
extension SecuritySchemaBuilder: ResolvableType {
    static var path: String { return "securitySchemes" }
    static var resolver: ReferenceResolver<SecuritySchemaBuilder> { return kSecuritySchemaBuilderReferenceResolver }
}

private let kExampleBuilderReferenceResolver = ReferenceResolver<ExampleBuilder>()
extension ExampleBuilder: ResolvableType {
    static var path: String { return "examples" }
    static var resolver: ReferenceResolver<ExampleBuilder> { return kExampleBuilderReferenceResolver }
}

private let kRequestBodyBuilderReferenceResolver = ReferenceResolver<RequestBodyBuilder>()
extension RequestBodyBuilder: ResolvableType {
    static var path: String { return "requestBodies" }
    static var resolver: ReferenceResolver<RequestBodyBuilder> { return kRequestBodyBuilderReferenceResolver }
}

private let kHeaderBuilderReferenceResolver = ReferenceResolver<HeaderBuilder>()
extension HeaderBuilder: ResolvableType {
    static var path: String { return "headers" }
    static var resolver: ReferenceResolver<HeaderBuilder> { return kHeaderBuilderReferenceResolver }
}

protocol Setupable {
    func setup()
    func teardown()
}

class ReferenceResolver<T: ResolvableType>: Setupable {
    enum ResolverError: Error {
        case invalidContext
        case invalidPath
        case unsupportedReference
        case unresolvedReference
    }

    private class Context<C> {
        /// Maintains a cache of previously resolved objects to prevent unnecessary resolutions.
        var cachedReferences = [String: C]()

        /// Maintains the set of references currently being resolved for cycle detection.
        var resolvingReferences = Set<String>()
    }

    /// The current context for resolutions of type T.
    /// Maintains a cache of previously resolved buildings and tracks in-progress resolutions.
    private var context: Context<T.Building>?

    func setup() {
        self.context = Context<T.Building>()
    }

    func resolve(_ swagger: SwaggerBuilder, pointer: Pointer<T>) throws -> Structure<T.Building> {
        guard let context = self.context else {
            throw ResolverError.invalidContext
        }

        /// Parse the pointer's path:
        let components = pointer.path.components(separatedBy: "/")
        guard components.count == 4 && components[0] == "#" && components[2] == T.path else {
            throw ResolverError.invalidPath
        }

        /// Find the referenced builder (if any):
        let name = components[3]
        let referencedBuilder: Any?
        switch T.path {
        case "schemas": referencedBuilder = swagger.components?.schemas[name]
        case "parameters": referencedBuilder = swagger.components?.parameters[name]
        case "responses": referencedBuilder = swagger.components?.responses[name]
        case "securitySchemes": referencedBuilder = swagger.components?.securitySchemes[name]
        case "examples": referencedBuilder = swagger.components?.examples[name]
        case "requestBodies": referencedBuilder = swagger.components?.requestBodies[name]
        case "headers": referencedBuilder = swagger.components?.headers[name]
        default: throw ResolverError.unsupportedReference
        }

        // Check to see if the builder was found at the specified path:
        guard let builderRef = (referencedBuilder as? Reference<T>) else {
            throw ResolverError.unresolvedReference
        }
        
        if case let Reference.pointer(pointer) = builderRef {
            // Check to see if we have encountered a cyclic reference:
            if context.resolvingReferences.contains(name) {
                return Structure(name: name, structure: nil)
            }
            
            // Push the resolving reference into the context to detect cyclic references.
            context.resolvingReferences.insert(name)

            return try resolve(swagger, pointer: pointer)
        }
        
        guard case let Reference.value(builder) = builderRef else {
            throw ResolverError.unresolvedReference
        }

        // Look for a cached, resolved building (potentially it was already built for another type):
        if let cached = context.cachedReferences[name] {
            return Structure(name: name, structure: cached)
        }

        // Check to see if we have encountered a cyclic reference:
        if context.resolvingReferences.contains(name) {
            return Structure(name: name, structure: nil)
        }

        // Push the resolving reference into the context to detect cyclic references.
        context.resolvingReferences.insert(name)

        // Build and cache the builder's building.
        let resolved = try builder.build(swagger)
        context.cachedReferences[name] = resolved

        // Pop the resolving reference from the context as the building has been successfully resolved.
        context.resolvingReferences.remove(name)

        // Construct and return a structure containing the resolved building.
        return Structure(name: name, structure: resolved)
    }
    
    func teardown() {
        self.context  = nil
    }
}
