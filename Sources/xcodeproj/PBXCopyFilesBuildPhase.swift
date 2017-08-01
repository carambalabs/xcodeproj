import Foundation
import Unbox
import xcodeprojextensions

// This is the element for the copy file build phase.
public struct PBXCopyFilesBuildPhase {
    
    public enum SubFolder: UInt, UnboxableEnum {
        case absolutePath = 0
        case productsDirectory = 16
        case wrapper = 1
        case executables = 6
        case resources = 7
        case javaResources = 15
        case frameworks = 10
        case sharedFrameworks = 11
        case sharedSupport = 12
        case plugins = 13
        case other
    }

    // MARK: - Attributes
    
    /// Element reference
    public var reference: String
    
    /// Element destination path
    public var dstPath: String
    
    /// Element build action mask.
    public var buildActionMask: UInt
    
    /// Element destination subfolder spec
    public var dstSubfolderSpec: SubFolder
 
    /// Element files
    public var files: Set<String>
 
    /// element run only for deployment post processing.
    public var runOnlyForDeploymentPostprocessing: UInt
    
    // MARK: - Init
    
    /// Initializes the copy files build phase with its attributes.
    ///
    /// - Parameters:
    ///   - reference: reference. Will be automatically generated if not specified
    ///   - dstPath: destination path.
    ///   - dstSubfolderSpec: destination subfolder spec.
    ///   - buildActionMask: build action mask.
    ///   - files: files to copy.
    ///   - runOnlyForDeploymentPostprocessing: run only for deployment post processing.
    public init(reference: String? = nil,
                dstPath: String,
                dstSubfolderSpec: SubFolder,
                buildActionMask: UInt = 2147483647,
                files: Set<String> = [],
                runOnlyForDeploymentPostprocessing: UInt = 0) {
        self.reference = reference ??
            ReferenceGenerator.shared.generateReference(PBXCopyFilesBuildPhase.self,
                                                        dstPath + dstSubfolderSpec.hashValue.description + files.joined())
        self.dstPath = dstPath
        self.buildActionMask = buildActionMask
        self.dstSubfolderSpec = dstSubfolderSpec
        self.files = files
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
    }
    
}

// MARK: - PBXCopyFilesBuildPhase Extension (ProjectElement)

extension PBXCopyFilesBuildPhase: ProjectElement {
    
    public init(reference: String, dictionary: [String : Any]) throws {
        self.reference = reference
        let unboxer = Unboxer(dictionary: dictionary)
        self.dstPath = try unboxer.unbox(key: "dstPath")
        self.buildActionMask = try unboxer.unbox(key: "buildActionMask")
        let dstSubFolderSpecInt: UInt = try unboxer.unbox(key: "dstSubfolderSpec")
        self.dstSubfolderSpec = SubFolder(rawValue: dstSubFolderSpecInt) ?? .other
        self.files = try unboxer.unbox(key: "files")
        self.runOnlyForDeploymentPostprocessing = try unboxer.unbox(key: "runOnlyForDeploymentPostprocessing")
    }
    
    public static func == (lhs: PBXCopyFilesBuildPhase,
                           rhs: PBXCopyFilesBuildPhase) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.dstPath == rhs.dstPath &&
            lhs.buildActionMask == rhs.buildActionMask &&
            lhs.dstSubfolderSpec == rhs.dstSubfolderSpec &&
            lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
    
    public var hashValue: Int { return self.reference.hashValue }
    
}

// MARK: - PBXCopyFilesBuildPhase Extension (PlistSerializable)

extension PBXCopyFilesBuildPhase: PlistSerializable {
    
    public static var isa: String = "PBXCopyFilesBuildPhase"
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXCopyFilesBuildPhase.isa))
        dictionary["buildActionMask"] = .string(CommentedString("\(buildActionMask)"))
        dictionary["dstPath"] = .string(CommentedString(dstPath))
        dictionary["dstSubfolderSpec"] = .string(CommentedString("\(dstSubfolderSpec.rawValue)"))
        dictionary["files"] = .array(self.files
            .map { reference in
                let fileName = proj.buildFileName(reference: reference).flatMap { "\($0) in CopyFiles" }
                return PlistValue.string(CommentedString(reference, comment: fileName))
            })
        dictionary["runOnlyForDeploymentPostprocessing"] = .string(CommentedString("\(runOnlyForDeploymentPostprocessing)"))
        return (key: CommentedString(self.reference,
                                                 comment: "CopyFiles"),
                value: .dictionary(dictionary))
    }
    
}
