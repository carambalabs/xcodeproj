import Foundation
import Unbox

// This element indicate a file reference that is used in a PBXBuildPhase (either as an include or resource).
public struct PBXBuildFile: ProjectElement {
    
    // MARK: - Attributes
    
    /// Element reference.
    public var reference: String
    
    /// Element isa.
    public static var isa: String = "PBXBuildFile"
    
    /// Element file reference.
    public var fileRef: String
    
    /// Element settings
    public var settings: [String: Any]?
    
    // MARK: - Init
    
    /// Initiazlies the build file with its attributes.
    ///
    /// - Parameters:
    ///   - reference: element reference. Will be automatically generated if not specified
    ///   - fileRef: build file reference.
    ///   - settings: build file settings.
    public init(reference: String? = nil,
                fileRef: String,
                settings: [String: Any]? = nil) {
        self.reference = reference ?? ReferenceGenerator.shared.generateReference(PBXBuildFile.self, fileRef)
        self.fileRef = fileRef
        self.settings = settings
    }
    
    /// Constructor that initializes the project element with the reference and a dictionary with its properties.
    ///
    /// - Parameters:
    ///   - reference: element reference.
    ///   - dictionary: dictionary with the element properties.
    /// - Throws: throws an error in case any of the propeties are missing or they have the wrong type.
    public init(reference: String, dictionary: [String : Any]) throws {
        self.reference = reference
        let unboxer = Unboxer(dictionary: dictionary)
        self.fileRef = try unboxer.unbox(key: "fileRef")
        self.settings = unboxer.unbox(key: "settings")
    }
    
    // MARK: - Hashable
    
    public static func == (lhs: PBXBuildFile,
                           rhs: PBXBuildFile) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.fileRef == rhs.fileRef &&
            NSDictionary(dictionary: lhs.settings ?? [:]).isEqual(to: rhs.settings ?? [:])
    }
    
    public var hashValue: Int { return self.reference.hashValue }
}

// MARK: - PBXBuildFile Extension (PlistSerializable)

extension PBXBuildFile: PlistSerializable {
    
    var multiline: Bool { return false }
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXBuildFile.isa))
        let fileName = name(fileRef: fileRef, proj: proj)
        dictionary["fileRef"] = .string(CommentedString(fileRef, comment: fileName))
        let fileType = proj.fileType(reference: reference)
        if let settings = settings {
            dictionary["settings"] = settings.plist()
        }
        let comment = fileName.flatMap({ fileName -> String? in return fileType.flatMap({"\(fileName) in \($0)"})})
        return (key: CommentedString(self.reference, comment: comment),
                value: .dictionary(dictionary))
    }
    
    private func name(fileRef: String, proj: PBXProj) -> String? {
        let fileReference = proj.objects.fileReferences.filter({$0.reference == fileRef}).first
        let variantGroup = proj.objects.variantGroups.filter({$0.reference == fileRef}).first
        if let fileReference = fileReference {
            return fileReference.name ?? fileReference.path
        } else if let variantGroup = variantGroup {
            return variantGroup.name
        }
        return nil
    }
    
    private func fileType(reference: String, proj: PBXProj) -> String? {
        if proj.objects.frameworksBuildPhases.filter({$0.files.contains(reference)}).count != 0 {
           return "Frameworks"
        } else if proj.objects.headersBuildPhases.filter({$0.files.contains(reference)}).count != 0 {
            return "Headers"
        } else if proj.objects.sourcesBuildPhases.filter({$0.files.contains(reference)}).count != 0 {
            return "Sources"
        } else if proj.objects.resourcesBuildPhases.filter({$0.files.contains(reference)}).count != 0 {
            return "Resources"
        }
        return nil
    }
    
}
