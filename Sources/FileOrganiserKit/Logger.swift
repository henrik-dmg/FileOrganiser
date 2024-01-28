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
        /// Skips the summmary at the end of the run. Useful for parsing the output.
        public static let skipSummary = Options(rawValue: 1 << 1)
    }

    // MARK: - Properties

    let options: Options
    let printer: Printer

    // MARK: - Init

    public convenience init(options: Options) {
        self.init(options: options, printer: Printer(outputFileHandle: .standardOutput, errorFileHandle: .standardError))
    }

    init(options: Options, printer: Printer) {
        self.options = options
        self.printer = printer
    }

    // MARK: - Methods

    public func logFileAction(sourcePath: String, destinationPath: String, fileStrategy: FileHandlingStrategy, isDryRun: Bool) {
        let arrow = isDryRun ? "~>" : "->"

        let logMessage =
            switch fileStrategy {
            case .move:
                "MOVE |> \(sourcePath) \(arrow) \(destinationPath)"
            case .copy:
                "COPY |> \(sourcePath) \(arrow) \(destinationPath)"
            }

        if isDryRun {
            printer.writeDefault(logMessage)
        } else {
            printVerbose(logMessage)
        }
    }

    public func logFileSkipped(at url: URL, reason: String) {
        printVerbose(
            "SKIP |> \(url.relativePath) (\(reason))".addingTerminalStyling(color: options.contains(.coloredOutput) ? .yellow : nil)
        )
    }

    public func logSummary(dryRun: Bool, filesProcessed: Int, filesWritten: Int, filesSkipped: Int, bytesWritten: Int) {
        guard !options.contains(.skipSummary) else {
            return
        }

        if dryRun {
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                        |> Dry run completed. No files were moved or copied.
                """
            printer.writeDefault(logMessage.addingTerminalStyling(color: options.contains(.coloredOutput) ? .green : nil))
        } else {
            let formatter = ByteCountFormatter()
            let bytesWrittenString = formatter.string(fromByteCount: Int64(bytesWritten))
            let logMessage = """
                SUCCESS |> Processed \(filesProcessed) files.
                        |> Files written: \(filesWritten) files (\(bytesWrittenString)). \(filesSkipped) files skipped.
                """
            printer.writeDefault(logMessage.addingTerminalStyling(color: options.contains(.coloredOutput) ? .green : nil))
        }
    }

    public func logError(message: String) {
        printer.writeError("ERROR |> \(message)".addingTerminalStyling(color: options.contains(.coloredOutput) ? .red : nil))
    }

    public func logSoftError(message: String) {
        printer.writeError("NON-FATAL |> \(message)".addingTerminalStyling(color: options.contains(.coloredOutput) ? .red : nil))
    }

    // MARK: - Helpers

    private func printVerbose(_ string: String) {
        guard options.contains(.verbose) else {
            return
        }

        printer.writeDefault(string)
    }

}
