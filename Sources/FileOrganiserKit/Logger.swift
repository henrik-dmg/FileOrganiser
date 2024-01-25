import Foundation

public class Logger {

    // MARK: - Nested Types

    public struct Options: OptionSet {

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Prints additional information during processing.
        public static let verbose = Options(rawValue: 1 << 0)
        /// Enables or disables colored output
        public static let coloredOutput = Options(rawValue: 1 << 1)
        /// Uses a more parseable output format
        public static let parseableOutput = Options(rawValue: 1 << 2)

    }

    // MARK: - Properties

    let options: Options
    var output: TextOutputStream
    var errorOutput: TextOutputStream

    // MARK: - Init

    public convenience init(options: Options) {
        self.init(options: options, output: FileHandleOutputStream(.standardOutput), errorOutput: FileHandleOutputStream(.standardError))
    }

    init(
        options: Options,
        output: TextOutputStream,
        errorOutput: TextOutputStream
    ) {
        self.options = options
        self.output = output
        self.errorOutput = errorOutput
    }

    // MARK: - Methods

    public func logFileWritten(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy) {
        let logMessage: String

        switch fileStrategy {
        case .move:
            logMessage =
                options.contains(.parseableOutput)
                ? "MOVE |> \(sourcePath) -> \(destinationPath)" : "Moved file from \(sourcePath) to \(destinationPath)"
        case .copy:
            logMessage =
                options.contains(.parseableOutput)
                ? "COPY |> \(sourcePath) -> \(destinationPath)" : "Copied file from \(sourcePath) to \(destinationPath)"
        }

        printVerbose(logMessage)
    }

    public func logDryRun(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy) {
        let logMessage: String

        switch fileStrategy {
        case .move:
            logMessage =
                options.contains(.parseableOutput)
                ? "MOVE |> \(sourcePath) -> \(destinationPath)" : "Would move file from \(sourcePath) to \(destinationPath)"
        case .copy:
            logMessage =
                options.contains(.parseableOutput)
                ? "COPY |> \(sourcePath) -> \(destinationPath)" : "Would copy file from \(sourcePath) to \(destinationPath)"
        }

        print(logMessage, to: &output)
    }

    public func logFileSkipped(at url: URL, reason: String) {
        if options.contains(.parseableOutput) {
            printVerbose("SKIP |> \(url.relativePath)")
        } else {
            printVerbose(
                "Skipping file at \(url.relativePath) (\(reason))"
                    .addingTerminalStyling(color: options.contains(.coloredOutput) ? .yellow : nil)
            )
        }
    }

    public func logSummary(dryRun: Bool, filesProcessed: Int, filesWritten: Int, filesSkipped: Int, bytesWritten: Int) {
        guard !options.contains(.parseableOutput) else {
            return
        }

        if dryRun {
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                        |> Dry run completed. No files were moved or copied.
                """
            print(logMessage.addingTerminalStyling(color: options.contains(.coloredOutput) ? .green : nil), to: &output)
        } else {
            let formatter = ByteCountFormatter()
            let bytesWrittenString = formatter.string(fromByteCount: Int64(bytesWritten))
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                        |> Files written: \(filesWritten) files (\(bytesWrittenString)). \(filesSkipped) files skipped.
                """
            print(logMessage.addingTerminalStyling(color: options.contains(.coloredOutput) ? .green : nil), to: &output)
        }
    }

    public func logError(message: String) {
        print("ERROR |> \(message)".addingTerminalStyling(color: options.contains(.coloredOutput) ? .red : nil), to: &errorOutput)
    }

    public func logSoftError(message: String) {
        print("NON-FATAL |> \(message)".addingTerminalStyling(color: options.contains(.coloredOutput) ? .red : nil), to: &errorOutput)
    }

    // MARK: - Helpers

    private func printVerbose(_ args: Any...) {
        guard options.contains(.verbose) else {
            return
        }

        let printString = args.map {
            String(describing: $0)
        }
        print(printString, separator: " ", to: &output)
    }

}
