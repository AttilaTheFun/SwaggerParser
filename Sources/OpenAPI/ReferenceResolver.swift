
public protocol ResolvableType: Builder {
    static var path: String { get }
}

//private let kSchemaBuilderReferenceResolver = ReferenceResolver<SchemaBuilder>()
//extension SchemaBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return (version.major >= 3) ? "schemas" : "definitions" }
//    static var resolver: ReferenceResolver<SchemaBuilder> { return kSchemaBuilderReferenceResolver }
//}
//
//private let kParameterBuilderReferenceResolver = ReferenceResolver<ParameterBuilder>()
//extension ParameterBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "parameters" }
//    static var resolver: ReferenceResolver<ParameterBuilder> { return kParameterBuilderReferenceResolver }
//}
//
//private let kResponseBuilderReferenceResolver = ReferenceResolver<ResponseBuilder>()
//extension ResponseBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "responses" }
//    static var resolver: ReferenceResolver<ResponseBuilder> { return kResponseBuilderReferenceResolver }
//}
//
//private let kSecuritySchemaBuilderReferenceResolver = ReferenceResolver<SecuritySchemaBuilder>()
//extension SecuritySchemaBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "securitySchemes" }
//    static var resolver: ReferenceResolver<SecuritySchemaBuilder> { return kSecuritySchemaBuilderReferenceResolver }
//}
//
//private let kExampleBuilderReferenceResolver = ReferenceResolver<ExampleBuilder>()
//extension ExampleBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "examples" }
//    static var resolver: ReferenceResolver<ExampleBuilder> { return kExampleBuilderReferenceResolver }
//}
//
//private let kRequestBodyBuilderReferenceResolver = ReferenceResolver<RequestBodyBuilder>()
//extension RequestBodyBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "requestBodies" }
//    static var resolver: ReferenceResolver<RequestBodyBuilder> { return kRequestBodyBuilderReferenceResolver }
//}
//
//private let kHeaderBuilderReferenceResolver = ReferenceResolver<HeaderBuilder>()
//extension HeaderBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "headers" }
//    static var resolver: ReferenceResolver<HeaderBuilder> { return kHeaderBuilderReferenceResolver }
//}
//
//private let kLinkBuilderReferenceResolver = ReferenceResolver<LinkBuilder>()
//extension LinkBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "links" }
//    static var resolver: ReferenceResolver<LinkBuilder> { return kLinkBuilderReferenceResolver }
//}
//
//private let kCallbackBuilderReferenceResolver = ReferenceResolver<CallbackBuilder>()
//extension CallbackBuilder: ResolvableType {
//    static func path(for version: Version) -> String { return "callbacks" }
//    static var resolver: ReferenceResolver<CallbackBuilder> { return kCallbackBuilderReferenceResolver }
//}

public protocol Setupable {
    func setup()
    func teardown()
}

public enum ResolverError: Error {
    case invalidContext
    case invalidPath
    case unsupportedReference
    case unresolvedReference
}

public class ReferenceResolver<T: ResolvableType>: Setupable {

    private class Context<C> {
        /// Maintains a cache of previously resolved objects to prevent unnecessary resolutions.
        var cachedReferences = [String: C]()

        /// Maintains the set of references currently being resolved for cycle detection.
        var resolvingReferences = Set<String>()
    }

    /// The current context for resolutions of type T.
    /// Maintains a cache of previously resolved buildings and tracks in-progress resolutions.
    private var context: Context<T.Building>?

    public func setup() {
        self.context = Context<T.Building>()
    }
    
    public func teardown() {
        self.context  = nil
    }

    public init() {
        
    }

    public func resolve(_ swagger: SwaggerBuilder, pointer: Pointer<T>) throws -> Structure<T.Building> {
        guard let context = self.context else {
            throw ResolverError.invalidContext
        }

        /// Parse the pointer's path:
        let components = pointer.path.components(separatedBy: "/")
        let name = try swagger.resolveBuilderName(from: components, at: T.path)
        let referencedBuilder = try swagger.resolveBuilder(for: name, at: T.path)

        // Check to see if the builder was found at the specified path:
        var refBuilder = referencedBuilder as? T
        if refBuilder == nil {
            guard let builderRef = referencedBuilder as? Reference<T> else {
                throw ResolverError.unresolvedReference
            }

            // Resolve references in reusable components itself
            if case let Reference.pointer(pointer) = builderRef {
                // Check to see if we have encountered a cyclic reference:
                if context.resolvingReferences.contains(name) {
                    return Structure(name: name, structure: nil)
                }

                // Push the resolving reference into the context to detect cyclic references.
                context.resolvingReferences.insert(name)

                return try resolve(swagger, pointer: pointer)
            }

            guard case Reference.value(let unreferencedBuilder) = builderRef else {
                throw ResolverError.unresolvedReference
            }
            refBuilder = unreferencedBuilder
        }

        guard let builder = refBuilder else {
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

}
