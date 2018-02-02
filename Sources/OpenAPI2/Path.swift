import OpenAPI

/// Describes the operations available on a single path.
public struct Path {

    /// The definitions of the operations on this path.
    public let operations: [OperationType: Operation]

    /// A list of parameters that are applicable for all the operations described under this path. 
    /// These parameters can be overridden at the operation level, but cannot be removed there.
    /// There can be one "body" parameter at most.
    public let parameters: [Either<Parameter, Structure<Parameter>>]
}

struct PathBuilder: Codable {
    let operations: [OperationType: OperationBuilder]
    let parameters: [Reference<ParameterBuilder>]

    enum CodingKeys: String, CodingKey {
        case parameters
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let operations = try [String: OperationBuilder](from: decoder)
        let operationTuples = operations.flatMap { tuple -> (OperationType, OperationBuilder)? in
            guard let type = OperationType(rawValue: tuple.key) else {
                return nil
            }

            return (type, tuple.value)
        }

        self.operations = Dictionary(uniqueKeysWithValues: operationTuples)
        self.parameters = try values.decodeIfPresent([Reference<ParameterBuilder>].self,
                                                     forKey: .parameters) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.operations.encode(to: encoder)
        try container.encode(self.parameters, forKey: .parameters)
    }
}

extension PathBuilder: Builder {
    typealias Building = Path

    func build(_ swagger: SwaggerBuilder) throws -> Path {
        let operations = try self.operations.mapValues { try $0.build(swagger) }
        let parameters = try self.parameters.map { try ParameterBuilder.resolve(swagger, reference: $0) }
        return Path(operations: operations, parameters: parameters)
    }
}
