import Foundation
import ObjectMapper

public enum ReferenceResolvingError: Error {
    case baseURL(URL)
    case definitions([String: Any])
    case definitionNameMismatch(existing: String, reference: String?)
    case paths([String: Any])
    case path([String: Any])
    case responses([String: Any])
    case properties([String: Any])
    case reference(String)
    case referenceContent(String)
    case referenceFragment(String)
    case referenceName(String?)
    case definitionNotFoundForFile(name: String, baseURL: URL)
}

extension Dictionary where Key == String {
    private typealias Definition = [String: Any]
    private typealias Definitions = [String: Definition]
    
    /// Returns a [String: Any] where all external model object definition 
    /// references found in 
    /// self["paths"][<path>][<method>]["responses"][<code>]["schema"]
    /// are read from disk and set at self["definitions"][<file_name>], and
    /// the "$ref" for those external references is updated to point to the 
    /// local definition found in self["definitions"].
    ///
    /// If a json file is found in the containing directory (or if it's 
    /// subdirectories) that is not referenced by the file found at 
    /// `baseSpecURL` then there must exist a reference to the unreferenced file 
    /// in self["definitions"] with a name that matches the filename without the 
    /// file extension.
    func resolvingReferences(withBaseSpecURL baseSpecURL: URL) throws -> [String: Any] {
        let baseURL = baseSpecURL.deletingLastPathComponent()
        
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: baseURL.path, isDirectory: &isDirectory)
        guard isDirectory.boolValue else {
            throw ReferenceResolvingError.baseURL(baseURL)
        }
        
        var newSelf = self as [String: Any]
        
        var definitions: Definitions
        if let existingDefinitions = self["definitions"] as? Definitions {
            definitions = try existingDefinitions.resolvingReferencesInDefinitions(withBaseURL: baseURL)
        } else {
            definitions = Definitions()
        }
        
        if let paths = self["paths"] as? [String: Any] {
            newSelf["paths"] = try paths.resolvingReferencesInPaths(withBaseURL: baseURL, definitions: &definitions)
        }
        
        newSelf["definitions"] = definitions
        
        let baseSpecFilename = (baseSpecURL.lastPathComponent as NSString).deletingPathExtension
        let expectedFileNames = Array(definitions.keys) + [baseSpecFilename]
        do {
            try baseURL.validatePresenceOfFiles(withFileNames: expectedFileNames, pathExtension: "json")
        } catch FilePresenceValidationError.invalidURL {
            throw ReferenceResolvingError.baseURL(baseURL)
        } catch FilePresenceValidationError.nameNotFoundForFile(let name) {
            throw ReferenceResolvingError.definitionNotFoundForFile(name: name, baseURL: baseURL)
        }
        
        return newSelf
    }
    
    private func resolvingReferencesInDefinitions(withBaseURL baseURL: URL) throws -> Definitions {
        guard let definitions = self as? Definitions else {
            throw ReferenceResolvingError.definitions(self)
        }
        
        var newDefinitions = Definitions()
        var resolvedDefinitions = Definitions()
        
        try definitions.forEach { (name, definition) in
            let resolvedDefinition = try definition.resolvingReferencesInSchema(withBaseURL: baseURL, definitions: &resolvedDefinitions)
            
            // Do not include resolved objects.
            if let referencePath = resolvedDefinition["$ref"] as? String {
                let referencePathComponents = referencePath.components(separatedBy: "/")
                guard
                    let refName = referencePathComponents.last,
                    refName == name else {
                        throw ReferenceResolvingError.definitionNameMismatch(existing: name, reference: referencePathComponents.last)
                }
                return
            }
            
            newDefinitions[name] = resolvedDefinition
        }
        
        newDefinitions += resolvedDefinitions
        
        return newDefinitions
    }
    
    private typealias Operation = [String: Any]
    private typealias Path = [String: Operation]
    private typealias Paths = [String: Path]
    
    private func resolvingReferencesInPaths(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Paths {
        guard let paths = self as? Paths else {
            throw ReferenceResolvingError.paths(self)
        }
        
        var newPaths = paths
        try paths.forEach { (pathName, path) in
            newPaths[pathName] = try path.resolvingReferencesInPath(withBaseURL: baseURL, definitions: &definitions)
        }
        return newPaths
    }
    
    private func resolvingReferencesInPath(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Path {
        guard let path = self as? Path else {
            throw ReferenceResolvingError.path(self)
        }
        
        var newPath = path
        try path.forEach { (operationType, operation) in
            newPath[operationType] = try operation.resolvingReferencesInOperation(withBaseURL: baseURL, definitions: &definitions)
        }
        return newPath
    }
    
    private typealias Response = [String: Any]
    private typealias Responses = [String: Response]
    
    private func resolvingReferencesInOperation(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Operation {
        var newOperation = self as Operation
        if let responses = self["responses"] as? Responses {
            newOperation["responses"] = try responses.resolvingReferencesInResponses(withBaseURL: baseURL, definitions: &definitions)
        }
        return newOperation
    }
    
    private func resolvingReferencesInResponses(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Responses {
        guard let responses = self as? Responses else {
            throw ReferenceResolvingError.responses(self)
        }
        
        var newResponses = responses
        try responses.forEach { (code, response) in
            newResponses[code] = try response.resolvingReferencesInResponse(withBaseURL: baseURL, definitions: &definitions)
        }
        return newResponses
    }
    
    private typealias Schema = [String: Any]
    
    private func resolvingReferencesInResponse(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Response {
        var newResponse = self as Response
        if let schema = self["schema"] as? Schema {
            newResponse["schema"] = try schema.resolvingReferencesInSchema(withBaseURL: baseURL, definitions: &definitions)
        }
        return newResponse
    }
    
    private typealias AllOfSchema = [Schema]
    private typealias Property = [String: Any]
    private typealias Properties = [String: Property]
    
    private func resolvingReferencesInSchema(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Schema {
        var newSelf = self as Schema
        if let properties = newSelf["properties"] as? Properties {
            newSelf["properties"] = try properties.resolvingReferencesInProperties(withBaseURL: baseURL, definitions: &definitions)
        }
        
        if let items = newSelf["items"] as? Schema {
            newSelf["items"] = try items.resolvingReferencesInSchema(withBaseURL: baseURL, definitions: &definitions)
        }
        
        guard let ref = self["$ref"] as? String else {
            return newSelf
        }
        
        // If url has no content (fragment only) then this is a local reference
        // (e.g. "#/definitions/Foo") and no changes are necessary.
        guard
            let refURL = URL(string: ref),
            refURL.lastPathComponent.characters.count > 0 else {
                return newSelf
        }
        
        guard let absoluteRefURL = URL(string: ref, relativeTo: baseURL) else {
            throw ReferenceResolvingError.reference(ref)
        }
        
        let jsonString = try NSString(contentsOfFile: absoluteRefURL.path, encoding: String.Encoding.utf8.rawValue) as String
        guard let unresolvedRefJSON = Mapper<SwaggerBuilder>.parseJSONStringIntoDictionary(JSONString: jsonString) else {
            throw ReferenceResolvingError.referenceContent(jsonString)
        }
        
        let refBaseURL = absoluteRefURL.deletingLastPathComponent()
        var refJSON = try unresolvedRefJSON.resolvingReferencesInSchema(withBaseURL: refBaseURL, definitions: &definitions)
        
        let name: String
        if let fragment = refURL.fragment {
            let fragments = fragment.components(separatedBy: "/")
            
            // TODO: Support nested json object pointers in references.
            guard fragments.count == 1 else {
                throw ReferenceResolvingError.referenceFragment(fragment)
            }
            
            guard let last = fragments.last, last.characters.count > 0 else {
                throw ReferenceResolvingError.referenceName(fragments.last)
            }
            name = last
        } else {
            name = refURL.deletingPathExtension().lastPathComponent
        }
        
        newSelf["$ref"] = "#/definitions/\(name)"
        
        if let refJSONAllOf = refJSON["allOf"] as? AllOfSchema {
            var newRefJSONAllOf = refJSONAllOf
            try refJSONAllOf.enumerated().forEach { (index, allOfSchema) in
                newRefJSONAllOf[index] = try allOfSchema.resolvingReferencesInSchema(withBaseURL: refBaseURL, definitions: &definitions)
            }
            refJSON["allOf"] = newRefJSONAllOf
        }
        
        definitions[name] = refJSON
        
        return newSelf
    }
    
    private func resolvingReferencesInProperties(withBaseURL baseURL: URL, definitions: inout Definitions) throws -> Properties {
        guard let properties = self as? Properties else {
            throw ReferenceResolvingError.properties(self)
        }
        
        var newProperties = properties
        try properties.forEach { (propertyName, property) in
            newProperties[propertyName] = try property.resolvingReferencesInSchema(withBaseURL: baseURL, definitions: &definitions)
        }
        return newProperties
    }
}

enum FilePresenceValidationError: Error {
    case invalidURL
    case nameNotFoundForFile(name: String)
}

extension URL {
    /// Enumerates all files with the provided extension in the reciever's 
    /// directory and asserts that a string exists in `names` that matches the 
    /// file's name. This function can throw `FilePresenceValidationError`s.
    func validatePresenceOfFiles(withFileNames names: [String], pathExtension: String) throws {
        guard let enumerator = FileManager.default.enumerator(atPath: self.path) else {
            throw FilePresenceValidationError.invalidURL
        }
        
        while let filename = enumerator.nextObject() as? NSString {
            guard filename.pathExtension == pathExtension else {
                continue
            }
            
            let name = (filename.lastPathComponent as NSString).deletingPathExtension
            if !names.contains(name) {
                throw FilePresenceValidationError.nameNotFoundForFile(name: name)
            }
        }
    }
}

fileprivate func += <Key, Value> (left: inout [Key: Value], right: [Key: Value]) {
    right.forEach {left[$0.key] = $0.value}
}

extension ReferenceResolvingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .baseURL(let url):
            return "Invalid base URL: \(url)."
        case .definitions(let definitions):
            return "Invalid definitions: \(definitions)."
        case .definitionNameMismatch(let existing, let reference):
            return "Definition name '\(existing)' does not match reference file name '\(reference ?? "<invalid>")'."
        case .paths(let paths):
            return "Invalid paths: \(paths)."
        case .path(let path):
            return "Invalid path: \(path)."
        case .responses(let responses):
            return "Invalid responses: \(responses)"
        case .properties(let properties):
            return "Invalid properties: \(properties)"
        case .reference(let reference):
            return "Invalid reference: \(reference)"
        case .referenceContent(let jsonString):
            return "Invalid reference content: \(jsonString)"
        case .referenceFragment(let fragment):
            return "Invalid reference fragment: \(fragment)"
        case .referenceName(let name):
            return "Invalid reference name: \(name ?? "<nil>")"
        case .definitionNotFoundForFile(let name, let baseURL):
            return "Definition not found for file named \(name) at \(baseURL)."
        }
    }
}
