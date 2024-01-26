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

        do {
            try Organiser(fileHandler: fileHandler, logger: logger)
                .process(
                    sourceURL: options.source,
                    destinationURL: options.destination,
                    globPattern: options.filePattern,
                    fileStrategy: strategy,
                    dateStrategy: options.dateStrategy,
                    dryRun: options.dryRun,
                    shouldSoftFail: options.softFail
                )
        } catch let error as NSError {
            logger.logError(message: error.localizedDescription)
            Darwin.exit(Int32(error.code))
        }
    }

}
