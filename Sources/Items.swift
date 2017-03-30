import ObjectMapper

/// A limited subset of JSON-Schema's items object.
/// It is used by parameter definitions that are not located in "body".
public indirect enum Items: ImmutableMappable {
    case string(item: StringItem)
    case number(item: NumberItem)
    case integer(item: IntegerItem)
    case array(item: ArrayItem)
    case boolean(item: BooleanItem)

    public init(map: Map) throws {
        let metadata: BooleanItem = try Metadata(map: map)
        switch metadata.type {
        case .string:
            self = .string(item: try StringItem(map: map))
        case .number:
            self = .number(item: try NumberItem(map: map))
        case .integer:
            self = .integer(item: try IntegerItem(map: map))
        case .boolean:
            self = .boolean(item: metadata)
        case .array:
            self = .array(item: try ArrayItem(map: map))
        case .enumeration, .object:
            throw DecodingError()
        }
    }

    public struct StringItem: ImmutableMappable {
        public let metadata: Metadata
        public let format: StringFormat?

        public let maxLength: Int?
        public let minLength: Int?

        public init(map: Map) throws {
            metadata = try Metadata(map: map)
            format = try? map.value("format")

            maxLength = try? map.value("maxLength")
            minLength = (try? map.value("minLength")) ?? 0
        }
    }

    public struct NumberItem: ImmutableMappable {
        public let metadata: Metadata
        public let format: NumberFormat?

        public let maximum: Double?
        public let exclusiveMaximum: Double?
        public let minimum: Double?
        public let exclusiveMinimum: Double?
        public let multipleOf: Double?

        public init(map: Map) throws {
            metadata = try Metadata(map: map)
            format = try? map.value("format")

            maximum = try? map.value("maximum")
            exclusiveMaximum = try? map.value("exclusiveMaximum")
            minimum = try? map.value("minimum")
            exclusiveMinimum = try? map.value("exclusiveMinimum")
            multipleOf = try? map.value("multipleOf")
        }
    }

    public struct IntegerItem: ImmutableMappable {

        public let metadata: Metadata
        public let format: IntegerFormat?

        public let maximum: Int?
        public let exclusiveMaximum: Int?
        public let minimum: Int?
        public let exclusiveMinimum: Int?
        public let multipleOf: Int?

        public init(map: Map) throws {
            metadata = try Metadata(map: map)
            format = try? map.value("format")

            maximum = try? map.value("maximum")
            exclusiveMaximum = try? map.value("exclusiveMaximum")
            minimum = try? map.value("minimum")
            exclusiveMinimum = try? map.value("exclusiveMinimum")
            multipleOf = try? map.value("multipleOf")
        }
    }

    public typealias BooleanItem = Metadata

    public struct ArrayItem: ImmutableMappable {

        public let metadata: Metadata

        /// Describes the type of items in the array.
        public let items: Items

        /// Determines the format of the array if type array is used.
        public let collectionFormat: CollectionFormat

        /// Must be greater than or equal to zero.
        public let maxItems: Int?

        /// Must be greater than or equal to zero.
        public let minItems: Int

        public let uniqueItems: Bool

        public init(map: Map) throws {
            metadata = try Metadata(map: map)
            items = try map.value("items")
            collectionFormat = (try? map.value("collectionFormat")) ?? .csv

            maxItems = try? map.value("maxItems")
            minItems = (try? map.value("minItems")) ?? 0
            uniqueItems = (try? map.value("uniqueItems")) ?? false
        }
    }
}
