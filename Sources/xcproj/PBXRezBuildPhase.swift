import Foundation

/// This is the element for the Build Carbon Resources build phase.
final public class PBXRezBuildPhase: PBXBuildPhase {

	public override var buildPhase: BuildPhase {
		return .carbonResources
	}

    public static func == (lhs: PBXRezBuildPhase,
                           rhs: PBXRezBuildPhase) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.buildActionMask == rhs.buildActionMask &&
            lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
}

// MARK: - PBXRezBuildPhase Extension (PlistSerializable)

extension PBXRezBuildPhase: PlistSerializable {

    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = plistValues(proj: proj)
        dictionary["isa"] = .string(CommentedString(PBXRezBuildPhase.isa))
        return (key: CommentedString(self.reference, comment: "Rez"), value: .dictionary(dictionary))
    }

}
