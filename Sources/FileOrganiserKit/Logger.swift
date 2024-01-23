import Foundation

// MARK: - Protocol

public protocol LoggerProtocol {

    func logFileWritten(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy)
    func logDryRun(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy)
    func logFileSkipped(at url: URL, reason: String)
    func logSummary(dryRun: Bool, filesProcessed: Int, filesWritten: Int, filesSkipped: Int, bytesWritten: Int)
    func logError(message: String)
    func logSoftError(message: String)

}

// MARK: - Default Implementation

public struct Logger: LoggerProtocol, VerbosePrinteable {

    // MARK: - Properties

    let verbose: Bool

    // MARK: - Init

    public init(verbose: Bool) {
        self.verbose = verbose
    }

    // MARK: - Methods

    public func logFileWritten(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy) {
        switch fileStrategy {
        case .move:
            printVerbose("Moved file from \(sourcePath) to \(destinationPath)")
        case .copy:
            printVerbose("Copied file from \(sourcePath) to \(destinationPath)")
        }
    }

    public func logDryRun(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy) {
        switch fileStrategy {
        case .move:
            printVerbose("Would move file from \(sourcePath) to \(destinationPath)")
        case .copy:
            printVerbose("Would copy file from \(sourcePath) to \(destinationPath)")
        }
    }

    public func logFileSkipped(at url: URL, reason: String) {
        printVerbose("Skipping file at \(url.relativePath) (\(reason))".addingTerminalColor(.yellow))
    }

    public func logSummary(dryRun: Bool, filesProcessed: Int, filesWritten: Int, filesSkipped: Int, bytesWritten: Int) {
        if dryRun {
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                SUCCESS |> Dry run completed. No files were moved or copied.
                """
            print(logMessage.addingTerminalColor(.green))
        } else {
            let formatter = ByteCountFormatter()
            let bytesWrittenString = formatter.string(fromByteCount: Int64(bytesWritten))
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                SUCCESS |> Files written: \(filesWritten) files (\(bytesWrittenString)). \(filesSkipped) files skipped.
                """
            print(logMessage.addingTerminalColor(.green))
        }
    }

    public func logError(message: String) {
        print("ERROR |> \(message)".addingTerminalStyling(color: .red, decoration: .bold))
    }

    public func logSoftError(message: String) {
        print("NON-FATAL |> \(message)".addingTerminalStyling(color: .red, decoration: .bold))
    }

}
