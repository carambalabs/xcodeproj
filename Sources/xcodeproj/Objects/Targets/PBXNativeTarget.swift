import Foundation

/// This is the element for a build target that produces a binary content (application or library).
public final class PBXNativeTarget: PBXTarget {
    // Target product install path.
    public var productInstallPath: String?

    /// Initializes the native target with its attributes.
    ///
    /// - Parameters:
    ///   - name: target name.
    ///   - buildConfigurationList: build configuratino list.
    ///   - buildPhases: build phases.
    ///   - buildRules: build rules.
    ///   - dependencies: dependencies.
    ///   - productInstallPath: product install path.
    ///   - productName: product name.
    ///   - product: product file reference.
    ///   - productType: product type.
    public init(name: String,
                buildConfigurationList: XCConfigurationList? = nil,
                buildPhases: [PBXBuildPhase] = [],
                buildRules: [PBXBuildRule] = [],
                dependencies: [PBXTargetDependency] = [],
                productInstallPath: String? = nil,
                productName: String? = nil,
                product: PBXFileReference? = nil,
                productType: PBXProductType? = nil) {
        self.productInstallPath = productInstallPath
        super.init(name: name,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies: dependencies,
                   productName: productName,
                   product: product,
                   productType: productType)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case productInstallPath
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productInstallPath = try container.decodeIfPresent(.productInstallPath)
        try super.init(from: decoder)
    }

    override func plistValues(proj: PBXProj, isa: String, reference: String) -> (key: CommentedString, value: PlistValue) {
        let (key, value) = super.plistValues(proj: proj, isa: isa, reference: reference)
        var dictionary = value.dictionary!
        if let productInstallPath = productInstallPath {
            dictionary["productInstallPath"] = .string(CommentedString(productInstallPath))
        }
        return (key: key, value: .dictionary(dictionary))
    }
}

// MARK: - PBXNativeTarget Extension (PlistSerializable)

extension PBXNativeTarget: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        return plistValues(proj: proj, isa: PBXNativeTarget.isa, reference: reference)
    }
}

// MARK: - Helpers

public extension PBXNativeTarget {
    /// Adds a local target dependency to the target.
    ///
    /// - Parameter target: dependency target.
    /// - Returns: target dependency reference.
    func addDependency(target: PBXTarget) -> PBXTargetDependency? {
        let objects = target.objects()
        guard let project = objects.projects.first?.value else {
            return nil
        }
        let proxy = PBXContainerItemProxy(containerPortal: .project(project),
                                          remoteGlobalID: .object(target),
                                          proxyType: .nativeTarget,
                                          remoteInfo: target.name)
        objects.add(object: proxy)
        let targetDependency = PBXTargetDependency(name: target.name,
                                                   target: target,
                                                   targetProxy: proxy)
        objects.add(object: targetDependency)
        dependencies.append(targetDependency)
        return targetDependency
    }
}
