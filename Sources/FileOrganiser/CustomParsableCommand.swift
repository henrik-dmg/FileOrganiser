import ArgumentParser
import FileOrganiserKit
import Foundation

protocol CustomParsableCommand: ParsableCommand {}

extension CustomParsableCommand {

    func runOrganiser(strategy: FileHandlingStrategy, options: Options) throws {
        var loggerOptions = Logger.Options()
        if options.coloredOutput {
            loggerOptions.insert(.coloredOutput)
        }
        if options.verbose {
            loggerOptions.insert(.verbose)
        }
        if options.parseableOutput {
            loggerOptions.insert(.parseableOutput)
        }

        let logger = Logger(options: loggerOptions)
        let fileHandler = FileHandler()
        let organiser = Organiser(fileHandler: fileHandler, logger: logger)

        do {
            let result = try organiser.processWithResult(
                sourceURL: options.source,
                destinationURL: options.destination,
                globPattern: options.filePattern,
                fileStrategy: strategy,
                dateStrategy: options.dateStrategy,
                dryRun: options.dryRun,
                shouldSoftFail: options.softFail
            )

            logger.logSummary(
                dryRun: options.dryRun,
                filesProcessed: result.filesProcessed,
                filesWritten: result.filesWritten,
                filesSkipped: result.filesSkipped,
                bytesWritten: result.bytesWritten
            )
        } catch let error as NSError {
            logger.logError(message: error.localizedDescription)
            Darwin.exit(Int32(error.code))
        }
    }

}
