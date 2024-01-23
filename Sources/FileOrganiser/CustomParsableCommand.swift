import ArgumentParser
import FileOrganiserKit
import Foundation

protocol CustomParsableCommand: ParsableCommand {}

extension CustomParsableCommand {

    func runOrganiser(strategy: FileHandlingStrategy, options: Options) throws {
        let logger: LoggerProtocol = Logger(verbose: options.verbose)
        let fileHandler: FileHandlerProtocol = FileHandler()

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
