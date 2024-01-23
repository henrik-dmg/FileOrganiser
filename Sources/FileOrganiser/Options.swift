import ArgumentParser
import FileOrganiserKit
import Foundation

struct Options: ParsableArguments {

    @Argument(
        help: "The directory from which you want to copy or move files",
        completion: .directory,
        transform: URL.init(fileURLWithPath:)
    )
    var source: URL

    @Argument(help: "The directory matched files will be copied or moved to", completion: .directory, transform: URL.init(fileURLWithPath:))
    var destination: URL

    @Option(help: "An optional name pattern to match files against. Only matched files will be moved or copied")
    var filePattern: String?

    @Option(
        help: """
            The strategy with which files are grouped into subfolders.
            For more information, please visit https://github.com/henrik-dmg/FileOrganiser#date-grouping-strategies
            """,
        completion: .list(DateGroupingStrategy.allCases.map({ $0.rawValue }))
    )
    var dateStrategy: DateGroupingStrategy = .month

    @Flag(help: "Only print the actions that would be performed, but do not actually perform them")
    var dryRun = false

    @Flag(help: "Prints additional information during processing")
    var verbose = false

    @Flag(help: "Keeps the tool running when a failure occurs for individual files")
    var softFail = false

}
