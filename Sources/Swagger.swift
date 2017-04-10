import Foundation
import ObjectMapper

public struct Swagger {

    /// Specifies the Swagger Specification version being used. It can be used by the Swagger UI and other 
    /// clients to interpret the API listing. The value MUST be "2.0".
    public let version: Version

    /// Provides metadata about the API. The metadata can be used by the clients if needed.
    public let information: Information

    /// The host (name or ip) serving the API. This MUST be the host only and does not include the scheme nor 
    /// sub-paths. It MAY include a port. If the host is not included, the host serving the documentation is 
    /// to be used (including the port).
    public let host: URL?

    /// The base path on which the API is served, which is relative to the host. 
    /// If it is not included, the API is served directly under the host. 
    /// The value MUST start with a leading slash (/). The basePath does not support path templating.
    public let basePath: String?

    /// The transfer protocol of the API.
    public let schemes: [TransferScheme]?

    /// A list of MIME types the APIs can consume. 
    /// This is global to all APIs but can be overridden on specific API calls.
    public let consumes: [String]?

    /// A list of MIME types the APIs can produce.
    /// This is global to all APIs but can be overridden on specific API calls.
    public let produces: [String]?

    /// The available paths and operations for the API.
    public let paths: [String : Path]

    /// An object to hold data types produced and consumed by operations.
    public let definitions: [Structure<Schema>]

    /// An object to hold parameters that can be used across operations.
    /// This property does NOT define global parameters for all operations.
    public let parameters: [Structure<Parameter>]

    /// An object to hold responses that can be used across operations.
    /// This property does NOT define global responses for all operations.
    public let responses: [Structure<Response>]

    /// Declares the security schemes to be used in the specification.
    /// This does not enforce the security schemes on the operations and only serves to provide the relevant 
    /// details for each scheme.
    public let securityDefinitions: [String : SecuritySchema]
}

extension Swagger {
    public init(JSON: [String : Any]) throws {
        let builder = try SwaggerBuilder(JSON: JSON)
        self = try builder.build(builder)
    }

    public init(JSONString string: String) throws {
        let builder = try SwaggerBuilder(JSONString: string)
        self = try builder.build(builder)
    }
}

struct SwaggerBuilder: Builder {

    typealias Building = Swagger

    let version: Version
    let information: InformationBuilder
    let host: URL?
    let basePath: String?
    let schemes: [TransferScheme]?
    let consumes: [String]?
    let produces: [String]?

    let paths: [String : PathBuilder]
    let definitions: [String : SchemaBuilder]
    let parameters: [String : ParameterBuilder]
    let responses: [String : ResponseBuilder]
    let securityDefinitions: [String : SecuritySchemaBuilder]

    init(map: Map) throws {
        // Parse swagger version
        let swaggerVersion: Version = try map.value("swagger", using: VersionTransform())
        guard swaggerVersion.major == 2 && swaggerVersion.minor == 0 else {
            throw SwaggerVersionError()
        }
        version = swaggerVersion

        // Parse other fields
        information = try map.value("info")
        host = try? map.value("host", using: URLTransform())
        basePath = try? map.value("basePath")
        schemes = try? map.value("schemes")
        consumes = try? map.value("consumes")
        produces = try? map.value("produces")

        // Map the paths:
        paths = try map.value("paths")
        definitions = (try? map.value("definitions")) ?? [:]
        parameters = (try? map.value("parameters")) ?? [:]
        responses = (try? map.value("responses")) ?? [:]
        securityDefinitions = (try? map.value("securityDefinitions")) ?? [:]
    }

    func build(_ swagger: SwaggerBuilder) throws -> Swagger {
        let paths = try Dictionary(self.paths.map { ($0, try $1.build(swagger)) })
        let definitions = try self.definitions.map { name, builder in
            Structure(name: name, structure: try builder.build(swagger))
        }

        let parameters = try self.parameters.map { name, builder in
            Structure(name: name, structure: try builder.build(swagger))
        }

        let responses = try self.responses.map { name, builder in
            Structure(name: name, structure: try builder.build(swagger))
        }

        let securityDefinitions = try Dictionary(self.securityDefinitions.map { ($0, try $1.build(swagger)) })
        return Swagger(version: self.version, information: try self.information.build(swagger),
                       host: self.host, basePath: self.basePath, schemes: self.schemes,
                       consumes: self.consumes, produces: self.produces, paths: paths,
                       definitions: definitions, parameters: parameters, responses: responses,
                       securityDefinitions: securityDefinitions)
    }
}

