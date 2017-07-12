import ObjectMapper

/// A type binding a type definition (e.g. schema, parameter, response) to a name.
public struct Structure<T> {

    /// The name of the type being defined:
    public let name: String

    /// The structure associated with the name:
    public let structure: T!
}
