import Foundation
import GlobPattern
import ImageIO

// MARK: - Protocol

public protocol FileHandlerProtocol {

    func doesFileExist(at url: URL) -> Bool
    func resourceValues(of url: URL, useExifMetadataIfPossible: Bool) throws -> FileAttributes?

    func copyItem(at source: URL, to target: URL) throws
    func moveItem(at source: URL, to target: URL) throws
    func createDirectory(at url: URL) throws

    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions,
        shouldSoftFail: Bool,
        callback: (URL) throws -> Void,
        softFailCallback: (Error) -> Void
    ) throws

}

// MARK: - Default Implementation

public struct FileHandler: FileHandlerProtocol {

    // MARK: - Nested Types

    enum FileHandlerError: LocalizedError {
        case cantCreateEnumerator(path: String)

        var errorDescription: String? {
            switch self {
            case .cantCreateEnumerator(let path):
                "Could not create file enumerator at path \(path)"
            }
        }
    }

    // MARK: - Init

    public init() {}

    // MARK: - Methods

    public func doesFileExist(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    public func resourceValues(of url: URL, useExifMetadataIfPossible: Bool) throws -> FileAttributes? {
        var fileAttributes = try FileAttributes(url: url)

        guard useExifMetadataIfPossible, fileAttributes.isRegularFileOrPackage else {
            return fileAttributes
        }

        do {
            let exifMetadata = try ExifParser.exifMetadata(ofFile: url)
            fileAttributes.photoCreationDate = exifMetadata.captureDate
            return fileAttributes
        } catch {
            guard error is ExifParser.ParserError else {
                throw error
            }
            print(error.localizedDescription.addingTerminalColor(.yellow))
            return fileAttributes
        }
    }

    public func copyItem(at source: URL, to target: URL) throws {
        try FileManager.default.copyItem(at: source, to: target)
    }

    public func moveItem(at source: URL, to target: URL) throws {
        try FileManager.default.moveItem(at: source, to: target)
    }

    public func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions,
        shouldSoftFail: Bool,
        callback: (URL) throws -> Void,
        softFailCallback: (Error) -> Void
    ) throws {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys, options: mask) else {
            throw FileHandlerError.cantCreateEnumerator(path: url.path)
        }

        for case let fileURL as URL in enumerator {
            do {
                try callback(fileURL)
            } catch let error {
                if shouldSoftFail {
                    softFailCallback(error)
                } else {
                    throw error
                }
            }
        }
    }

}
