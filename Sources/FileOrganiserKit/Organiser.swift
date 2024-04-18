import CLIFoundation
import Foundation
import GlobPattern

public class Organiser {

    // MARK: - Nested Types

    public struct DirectoryProcessingResult {
        public let filesProcessed: Int
        public let filesWritten: Int
        public let filesSkipped: Int
        public let bytesWritten: Int
    }

    enum FileProcessingResult {
        case skipped(reason: SkipReason)
        case written(sourcePath: String, destinationPath: String, fileSize: Int?)
        case notRegularFile
        case dryRun(sourcePath: String, destinationPath: String)
    }

    enum SkipReason: String {
        case alreadyExists, notMatchingGlob

        var description: String {
            switch self {
            case .alreadyExists:
                return "File already exists"
            case .notMatchingGlob:
                return "File does not match glob pattern"
            }
        }
    }

    // MARK: - Properties

    private let fileHandler: FileHandlerProtocol
    private let logger: Logger

    // MARK: - Init

    public init(fileHandler: FileHandlerProtocol, logger: Logger) {
        self.fileHandler = fileHandler
        self.logger = logger
    }

    // MARK: - Running Configurations

    public func processWithResult(
        sourceURL: URL,
        destinationURL: URL,
        globPattern: String?,
        fileStrategy: FileHandlingStrategy,
        dateStrategy: DateGroupingStrategy,
        dryRun: Bool,
        shouldSoftFail: Bool
    ) throws -> DirectoryProcessingResult {
        let glob: Glob.Pattern?
        if let globPattern, !globPattern.isEmpty {
            glob = try Glob.Pattern(globPattern, mode: .grouping)
        } else {
            glob = nil
        }

        var filesProcessed = 0
        var filesWritten = 0
        var filesSkipped = 0
        var bytesWritten = 0

        try fileHandler.contentsOfDirectory(
            at: sourceURL,
            includingPropertiesForKeys: Array(FileAttributes.urlResourceKeys),
            options: [.skipsHiddenFiles, .producesRelativePathURLs, .skipsPackageDescendants],
            shouldSoftFail: shouldSoftFail
        ) { url in
            if let glob, !glob.match(url.path) {
                logger.logFileSkipped(at: url, reason: SkipReason.notMatchingGlob.description)
                filesSkipped += 1
                filesProcessed += 1
                return
            }

            let processingResult = try processFile(
                at: url,
                destination: destinationURL,
                fileStrategy: fileStrategy,
                dateStrategy: dateStrategy,
                dryRun: dryRun
            )

            switch processingResult {
            case .skipped(let reason):
                logger.logFileSkipped(at: url, reason: reason.description)
                filesSkipped += 1
            case .written(let sourcePath, let destinationPath, let fileSize):
                logger.logFileAction(
                    sourcePath: sourcePath,
                    destinationPath: destinationPath,
                    fileStrategy: fileStrategy,
                    isDryRun: dryRun
                )
                filesWritten += 1
                bytesWritten += fileSize ?? 0
            case .dryRun(let sourcePath, let destinationPath):
                logger.logFileAction(
                    sourcePath: sourcePath,
                    destinationPath: destinationPath,
                    fileStrategy: fileStrategy,
                    isDryRun: dryRun
                )
            case .notRegularFile:
                return
            }

            filesProcessed += 1
        } softFailCallback: { error in
            logger.logSoftError(message: error.localizedDescription)
        }

        return DirectoryProcessingResult(
            filesProcessed: filesProcessed,
            filesWritten: filesWritten,
            filesSkipped: filesSkipped,
            bytesWritten: bytesWritten
        )
    }

    private func processFile(
        at url: URL,
        destination: URL,
        fileStrategy: FileHandlingStrategy,
        dateStrategy: DateGroupingStrategy,
        dryRun: Bool
    ) throws -> FileProcessingResult {
        guard let fileAttributes = try fileHandler.resourceValues(of: url),
            fileAttributes.isRegularFileOrPackage
        else {
            return .notRegularFile
        }

        let subFolderPath = fileAttributes.creationDate.path(for: dateStrategy)
        let subFolderURL = destination.appendingPathComponent(subFolderPath, isDirectory: true)
        let targetFileURL = subFolderURL.appendingPathComponent(url.lastPathComponent)

        if dryRun {
            return .dryRun(sourcePath: url.relativePath, destinationPath: targetFileURL.relativePath)
        }

        guard !fileHandler.doesFileExist(at: targetFileURL) else {
            return .skipped(reason: .alreadyExists)
        }

        try fileHandler.createDirectory(at: subFolderURL)

        switch fileStrategy {
        case .copy:
            try fileHandler.copyItem(at: url, to: targetFileURL)
        case .move:
            try fileHandler.moveItem(at: url, to: targetFileURL)

        }
        return .written(sourcePath: url.relativePath, destinationPath: targetFileURL.relativePath, fileSize: fileAttributes.fileSizeInBytes)
    }

}
