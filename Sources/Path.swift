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

// TODO: Handle $ref paths

/// Describes the operations available on a single path.
public struct Path: ImmutableMappable {

    /// The definitions of the operations on this path.
    public let operations: [OperationType : Operation]

    /// A list of parameters that are applicable for all the operations described under this path. 
    /// These parameters can be overridden at the operation level, but cannot be removed there.
    /// There can be one "body" parameter at most.
    public let parameters: [Reference<Parameter>]?

    public init(map: Map) throws {
        var mappedOperations = [OperationType : Operation]()
        for key in map.JSON.keys {
            if let operationType = OperationType(rawValue: key) {
                let operation: Operation = try map.value(key)
                mappedOperations[operationType] = operation
            }
        }
        operations = mappedOperations
        parameters = try? map.value("parameters")
    }
}
