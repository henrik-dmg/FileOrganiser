import Foundation

public struct FileAttributes {

    // MARK: - Nested Types

    enum FileAttributesError: LocalizedError {
        case unknownCreationDate

        var errorDescription: String? {
            switch self {
            case .unknownCreationDate:
                return "Could not read creation date of file"
            }
        }
    }

    // MARK: - Properties

    static let urlResourceKeys = Set<URLResourceKey>([.isRegularFileKey, .isPackageKey, .totalFileSizeKey, .creationDateKey, .fileSizeKey])

    public let fileSizeInBytes: Int?
    public let creationDate: Date

    // MARK: - Init

    init?(values: URLResourceValues) throws {
        guard let isRegularFile = values.isRegularFile, let isPackage = values.isPackage, isRegularFile || isPackage else {
            return nil  // Not a file or not a package
        }
        guard let creationDate = values.creationDate else {
            throw FileAttributesError.unknownCreationDate
        }
        self.fileSizeInBytes = values.fileSize ?? values.totalFileSize
        self.creationDate = creationDate
    }

    #if DEBUG
        init(fileSizeInBytes: Int?, creationDate: Date) {
            self.fileSizeInBytes = fileSizeInBytes
            self.creationDate = creationDate
        }
    #endif

}
