import ArgumentParser
import FileOrganiserKit
import Foundation

// MARK: - Root

@main struct FileOrganiser: ParsableCommand {

    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "file-organiser",
            abstract:
                "A tool to organise files from a source directory into a destination directory. Depending on the chosen date grouping strategy, files will be moved into subfolders",
            version: "1.0.0",
            subcommands: [Move.self, Copy.self],
            helpNames: .shortAndLong
        )
    }

}

// MARK: - Copy

struct Copy: CustomParsableCommand {

    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "copy",
            abstract:
                "Using this subcommand, matched files will be copied into the destination directory and the original files will remain at their location"
        )
    }

    @OptionGroup var options: Options

    func run() throws {
        try runOrganiser(strategy: .copy, options: options)
    }

}

// MARK: - Move

struct Move: CustomParsableCommand {

    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "move",
            abstract:
                "Using this subcommand, matched files will be moved into the destination directory and won't stay at their original location"
        )
    }

    @OptionGroup var options: Options

    func run() throws {
        try runOrganiser(strategy: .move, options: options)
    }

}

// MARK: - Helpers

extension FileHandlingStrategy: ExpressibleByArgument {}
extension DateGroupingStrategy: ExpressibleByArgument {}
