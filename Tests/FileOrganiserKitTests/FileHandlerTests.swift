import Foundation
import XCTest

@testable import FileOrganiserKit

final class FileHandlerTests: XCTestCase {

    // MARK: - Properties

    private var temporaryDirectory: URL?

    // MARK: - Test Lifecycle

    override func tearDownWithError() throws {
        if let temporaryDirectory {
            try FileManager.default.removeItem(at: temporaryDirectory)
            print("Cleaned up testing folder")
        }
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testFileHandler_CreatestTemporaryDirectory() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
            .appendingPathComponent("some-subfolder", conformingTo: .folder)

        let handler = FileHandler()
        try handler.createDirectory(at: temporaryDirectory)

        XCTAssertTrue(FileManager.default.fileExists(atPath: temporaryDirectory.path))
    }

    func testFileHandler_FileExists() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
            .appendingPathComponent("some-subfolder", conformingTo: .folder)

        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)

        let handler = FileHandler()
        XCTAssertTrue(handler.doesFileExist(at: temporaryDirectory))
    }

    func testFileHandler_CopiesItem() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        let sourceURL =
            temporaryDirectory
            .appendingPathComponent("source", conformingTo: .folder)
            .appendingPathComponent("text.txt", conformingTo: .text)
        let targetURL =
            temporaryDirectory
            .appendingPathComponent("target", conformingTo: .folder)
            .appendingPathComponent("text.txt", conformingTo: .plainText)

        try FileManager.default.createDirectory(at: sourceURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: targetURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "some-content".write(to: sourceURL, atomically: true, encoding: .utf8)

        let handler = FileHandler()
        try handler.copyItem(at: sourceURL, to: targetURL)

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
    }

    func testFileHandler_MovesItem() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        let sourceURL =
            temporaryDirectory
            .appendingPathComponent("source", conformingTo: .folder)
            .appendingPathComponent("text.txt", conformingTo: .text)
        let targetURL =
            temporaryDirectory
            .appendingPathComponent("target", conformingTo: .folder)
            .appendingPathComponent("text.txt", conformingTo: .plainText)

        try FileManager.default.createDirectory(at: sourceURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: targetURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "some-content".write(to: sourceURL, atomically: true, encoding: .utf8)

        let handler = FileHandler()
        try handler.moveItem(at: sourceURL, to: targetURL)

        XCTAssertFalse(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetURL.path))
    }

    func testFileHandler_CanReadMetadata() throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        let sourceURL = temporaryDirectory.appendingPathComponent("text.txt", conformingTo: .text)

        try "some-content".write(to: sourceURL, atomically: true, encoding: .utf8)

        let handler = FileHandler()
        let attributes = try XCTUnwrap(try handler.resourceValues(of: sourceURL, useExifMetadataIfPossible: false))

        XCTAssertTrue(attributes.isRegularFileOrPackage)
        XCTAssertTrue((attributes.fileSizeInBytes ?? 0) > 0)
    }

    // MARK: - Helpers

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("FileOrganiser", conformingTo: .folder)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.temporaryDirectory = directory
        return directory
    }

}
