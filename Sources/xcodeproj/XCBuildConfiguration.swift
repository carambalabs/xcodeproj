import Foundation
import Unbox

// This is the element for listing build configurations.
public struct XCBuildConfiguration {
   
    // MARK: - Attributes
    
    /// Build configuration reference.
    public var reference: String
    
    /// The path to a xcconfig file
    public var baseConfigurationReference: String?
    
    /// A map of build settings.
    public var buildSettings: BuildSettings
    
    /// The configuration name.
    public var name: String
    
    // MARK: - Init
    
    /// Initializes a build configuration.
    ///
    /// - Parameters:
    ///   - reference: build configuration reference. Will be automatically generated if not specified
    ///   - name: build configuration name.
    ///   - baseConfigurationReference: reference to the base configuration.
    ///   - buildSettings: dictionary that contains the build settings for this configuration.
    public init(reference: String? = nil,
                name: String,
                baseConfigurationReference: String? = nil,
                buildSettings: BuildSettings = [:]) {
        self.reference = reference ?? ReferenceGenerator.shared.generateReference(XCBuildConfiguration.self, name)
        self.baseConfigurationReference = baseConfigurationReference
        self.buildSettings = buildSettings
        self.name = name
    }
    
}

// MARK: - XCBuildConfiguration Extension (ProjectElement)

extension XCBuildConfiguration: ProjectElement {
    
    public static var isa: String = "XCBuildConfiguration"
    
    public var hashValue: Int { return self.reference.hashValue }
    
    public static func == (lhs: XCBuildConfiguration,
                           rhs: XCBuildConfiguration) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.baseConfigurationReference == rhs.baseConfigurationReference &&
            lhs.name == rhs.name &&
            NSDictionary(dictionary: lhs.buildSettings.dictionary).isEqual(to: rhs.buildSettings.dictionary)
    }
    
    public init(reference: String, dictionary: [String: Any]) throws {
        self.reference = reference
        let unboxer = Unboxer(dictionary: dictionary)
        self.baseConfigurationReference = unboxer.unbox(key: "baseConfigurationReference")
        self.buildSettings = BuildSettings(dictionary: (dictionary["buildSettings"] as? [String: Any]) ?? [:])
        self.name = try unboxer.unbox(key: "name")
    }
    
}

// MARK: - XCBuildConfiguration Extension (PlistSerializable)

extension XCBuildConfiguration: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(XCBuildConfiguration.isa))
        dictionary["name"] = .string(CommentedString(name))
        dictionary["buildSettings"] = buildSettings.dictionary.plist()
        if let baseConfigurationReference = baseConfigurationReference {
            let filename = proj.objects.fileName(from: baseConfigurationReference)
            dictionary["baseConfigurationReference"] = .string(CommentedString(baseConfigurationReference, comment: filename))
        }
        return (key: CommentedString(self.reference, comment: name), value: .dictionary(dictionary))
    }
    
}
