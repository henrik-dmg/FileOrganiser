import Foundation
import XCTest

class TemporaryFileTests: XCTestCase {

    private(set) var temporaryDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        temporaryDirectory = try FileManager.default.hp_makeTemporaryDirectory()
    }

    override func tearDownWithError() throws {
        if let temporaryDirectory {
            try FileManager.default.removeItem(at: temporaryDirectory)
        }
        try super.tearDownWithError()
    }

}

extension FileManager {

    // swift-format-ignore
    func hp_makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("FileOrganiser", conformingTo: .folder)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

}
