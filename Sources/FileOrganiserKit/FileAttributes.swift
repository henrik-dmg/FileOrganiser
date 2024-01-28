import Foundation

public struct FileAttributes {

    // MARK: - Nested Types

    enum FileAttributesError: LocalizedError {
        case unknownCreationDate(String)
        case unknownResourceType(String)

        var errorDescription: String? {
            switch self {
            case .unknownCreationDate(let path):
                "Could not read creation date of \(path)"
            case .unknownResourceType(let path):
                "\(path) has unknown resource type"
            }
        }
    }

    // MARK: - Properties

    static let urlResourceKeys = Set<URLResourceKey>([.isRegularFileKey, .isPackageKey, .totalFileSizeKey, .creationDateKey, .fileSizeKey])

    public let fileSizeInBytes: Int?
    public let creationDate: Date
    public let isRegularFileOrPackage: Bool

    // MARK: - Init

    public init(url: URL) throws {
        let resourceValues = try url.resourceValues(forKeys: Self.urlResourceKeys)
        guard let isRegularFile = resourceValues.isRegularFile, let isPackage = resourceValues.isPackage else {
            throw FileAttributesError.unknownResourceType(url.relativePath)
        }
        guard let creationDate = resourceValues.creationDate else {
            throw FileAttributesError.unknownCreationDate(url.relativePath)
        }
        self.fileSizeInBytes = resourceValues.fileSize ?? resourceValues.totalFileSize
        self.creationDate = creationDate
        self.isRegularFileOrPackage = isRegularFile || isPackage
    }

    #if DEBUG
        init(
            fileSizeInBytes: Int?,
            creationDate: Date,
            isRegularFileOrPackage: Bool
        ) {
            self.fileSizeInBytes = fileSizeInBytes
            self.creationDate = creationDate
            self.isRegularFileOrPackage = isRegularFileOrPackage
        }
    #endif

}
