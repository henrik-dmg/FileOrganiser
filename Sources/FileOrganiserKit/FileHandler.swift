import Foundation
import GlobPattern

// MARK: - Protocol

public protocol FileHandlerProtocol {

    func doesFileExist(at url: URL) -> Bool
    func resourceValues(of url: URL) throws -> FileAttributes?

    func copyItem(at source: URL, to target: URL) throws
    func moveItem(at source: URL, to target: URL) throws
    func createDirectory(at url: URL) throws

    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions,
        shouldSoftFail: Bool,
        fileHandler: (URL) throws -> Void,
        softFailHandler: (Error) -> Void
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

    public func resourceValues(of url: URL) throws -> FileAttributes? {
        try FileAttributes(url: url)
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
        fileHandler: (URL) throws -> Void,
        softFailHandler: (Error) -> Void
    ) throws {
        guard
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys, options: mask),
            FileManager.default.fileExists(atPath: url.path)
        else {
            throw FileHandlerError.cantCreateEnumerator(path: url.path)
        }

        for case let fileURL as URL in enumerator {
            do {
                try fileHandler(fileURL)
            } catch let error {
                if shouldSoftFail {
                    softFailHandler(error)
                } else {
                    throw error
                }
            }
        }
    }

}
