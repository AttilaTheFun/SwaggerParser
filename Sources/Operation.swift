import ObjectMapper

public struct Operation: ImmutableMappable {

    /// A short summary of what the operation does. This field SHOULD be less than 120 characters.
    public let summary: String?

    /// A verbose explanation of the operation behavior.
    /// Github-Flavored Markdown syntax can be used for rich text representation.
    public let description: String?

    /// A list of parameters that are applicable for this operation. 
    /// If a parameter is already defined at the Path Item, the new definition will override it, 
    /// but can never remove it. The list MUST NOT include duplicated parameters.
    /// There can be one "body" parameter at most.
    public let parameters: [Reference<Parameter>]

    /// The list of possible responses as they are returned from executing this operation.
    public let responses: [Int : Reference<Response>]

    /// The documentation of responses other than the ones declared for specific HTTP response codes.
    /// It can be used to cover undeclared responses.
    public let defaultResponse: Reference<Response>?

    /// Declares this operation to be deprecated. Usage of the declared operation should be refrained. 
    /// Default value is false.
    public let deprecated: Bool

    public init(map: Map) throws {
        summary = try? map.value("summary")
        description = try? map.value("description")
        parameters = (try? map.value("parameters")) ?? []

        let allResponses: [String : Reference<Response>] = try map.value("responses")
        var mappedResponses = [Int : Reference<Response>]()
        for (key, value) in allResponses {
            if let intKey = Int(key) {
                mappedResponses[intKey] = value
            }
        }

        responses = mappedResponses
        defaultResponse = allResponses["default"]
        deprecated = (try? map.value("deprecated")) ?? false
    }
}
