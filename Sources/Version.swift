import ObjectMapper

public class VersionTransform: TransformType {
    public typealias Object = Version
    public typealias JSON = String
    public func transformFromJSON(_ value: Any?) -> Version? {
        var convertible: LosslessStringConvertible? = value as? String
        convertible = convertible ?? value.flatMap({ $0 as? Double })
        convertible = convertible ?? value.flatMap({ $0 as? Float })
        guard let string = convertible?.description else {
            return nil
        }

        let components = string.components(separatedBy: ".")
        guard components.count >= 1, let major = Int(components[0]) else {
            return nil
        }

        let minor = components.count >= 2 ? Int(components[1]) : nil
        let patch = components.count >= 3 ? Int(components[2]) : nil
        return Version(major: major, minor: minor, patch: patch)
    }

    public func transformToJSON(_ value: Version?) -> String? {
        if let value = value {
            let components = [value.major, value.minor, value.patch].flatMap { $0 }
            return components.map{ "\($0)" }.joined(separator: ".")
        }
        return nil
    }
}

public struct Version {
    public let major: Int
    public let minor: Int?
    public let patch: Int?
}
