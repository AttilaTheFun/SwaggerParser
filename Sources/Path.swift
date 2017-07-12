import ObjectMapper

public enum OperationType: String {
    case get
    case put
    case post
    case delete
    case options
    case head
    case patch
}

/// Describes the operations available on a single path.
public struct Path {

    /// The definitions of the operations on this path.
    public let operations: [OperationType : Operation]

    /// A list of parameters that are applicable for all the operations described under this path. 
    /// These parameters can be overridden at the operation level, but cannot be removed there.
    /// There can be one "body" parameter at most.
    public let parameters: [Either<Parameter, Structure<Parameter>>]
}

struct PathBuilder: Builder {

    typealias Building = Path

    let operations: [OperationType : OperationBuilder]
    let parameters: [Reference<ParameterBuilder>]

    init(map: Map) throws {
        var mappedOperations = [OperationType : OperationBuilder]()
        for key in map.JSON.keys {
            if let operationType = OperationType(rawValue: key) {
                let operation: OperationBuilder = try map.value(key)
                mappedOperations[operationType] = operation
            }
        }
        operations = mappedOperations
        parameters = (try? map.value("parameters")) ?? []
    }

    func build(_ swagger: SwaggerBuilder) throws -> Path {
        let operations = try Dictionary(self.operations.map { ($0, try $1.build(swagger)) })
        let parameters = try self.parameters.map { try ParameterBuilder.resolve(swagger, reference: $0) }
        return Path(operations: operations, parameters: parameters)
    }
}
