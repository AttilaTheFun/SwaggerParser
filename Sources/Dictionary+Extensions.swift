
extension Dictionary {
    init(_ array: [(Key, Value)]) {
        var dictionary = Dictionary<Key, Value>(minimumCapacity: array.count)
        array.forEach { dictionary[$0.0] = $0.1 }
        self = dictionary
    }
}
