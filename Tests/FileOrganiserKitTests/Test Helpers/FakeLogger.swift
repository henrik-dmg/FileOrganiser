import Foundation
import XCTest

@testable import FileOrganiserKit

/// Fake logger to prevent spamming console output in tests
struct FakeLogger: LoggerProtocol {

    func logFileWritten(sourcePath: String, destinationPath: String, fileStrategy: FileOrganiserKit.FileHandlingStrategy) {}
    func logDryRun(sourcePath: String, destinationPath: String, fileStrategy: FileOrganiserKit.FileHandlingStrategy) {}
    func logFileSkipped(at url: URL, reason: String) {}
    func logSummary(dryRun: Bool, filesProcessed: Int, filesWritten: Int, filesSkipped: Int, bytesWritten: Int) {}
    func logError(message: String) {}
    func logSoftError(message: String) {}

}
