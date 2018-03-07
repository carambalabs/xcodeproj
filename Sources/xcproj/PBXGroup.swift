import Foundation

final public class PBXGroup: PBXFileElement {

    // MARK: - Attributes

    /// Element children.
    public var children: [String]

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - children: group children.
    ///   - sourceTree: group source tree.
    ///   - name: group name.
    ///   - path: group path.
    ///   - wrapsLines: should the IDE wrap lines for files in the group?
    ///   - usesTabs: group uses tabs.
    public init(children: [String],
                sourceTree: PBXSourceTree? = nil,
                name: String? = nil,
                path: String? = nil,
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil) {
        self.children = children
        super.init(sourceTree: sourceTree,
                   path: path,
                   name: name,
                   includeInIndex: includeInIndex,
                   usesTabs: usesTabs,
                   indentWidth: indentWidth,
                   tabWidth: tabWidth,
                   wrapsLines: wrapsLines)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXGroup,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.children == rhs.children
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case children
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.children = (try container.decodeIfPresent(.children)) ?? []
        try super.init(from: decoder)
    }
    
    // MARK: - PlistSerializable
    
    override func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(PBXGroup.isa))
        dictionary["children"] = .array(children.map({ (fileReference) -> PlistValue in
            let comment = proj.objects.fileName(fileReference: fileReference)
            return .string(CommentedString(fileReference, comment: comment))
        }))

        return (key: CommentedString(reference,
                                     comment: self.name ?? self.path),
                value: .dictionary(dictionary))
    }
}
