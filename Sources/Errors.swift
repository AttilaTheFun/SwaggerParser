
public struct DecodingError: Error {
    public let localizedDescription: String
    public let file: String
    public let line: Int

    init(_ localizedDescription: String, file: String = #file, line: Int = #line) {
        self.localizedDescription = localizedDescription
        self.file = file
        self.line = line
    }
}

public struct SwaggerVersionError: Error {}
