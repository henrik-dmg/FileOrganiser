import Foundation
import XCTest

@testable import FileOrganiserKit

final class FileHandlerTests: TemporaryFileTests {

    // MARK: - Tests

    func testFileHandler_CreatestTemporaryDirectory() throws {
        let folderURL = temporaryDirectory.appendingPathComponent("some-subfolder", conformingTo: .folder)

        let handler = FileHandler()
        try handler.createDirectory(at: folderURL)

        XCTAssertTrue(FileManager.default.fileExists(atPath: folderURL.path))
    }

    func testFileHandler_FileExists() throws {
        let folderURL = temporaryDirectory.appendingPathComponent("some-subfolder", conformingTo: .folder)

        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let handler = FileHandler()
        XCTAssertTrue(handler.doesFileExist(at: folderURL))
    }

    func testFileHandler_CopiesItem() throws {
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
        let sourceURL = temporaryDirectory.appendingPathComponent("text.txt", conformingTo: .text)

        try "some-content".write(to: sourceURL, atomically: true, encoding: .utf8)

        let handler = FileHandler()
        let attributes = try XCTUnwrap(try handler.resourceValues(of: sourceURL, useExifMetadataIfPossible: false))

        XCTAssertTrue(attributes.isRegularFileOrPackage)
        XCTAssertTrue((attributes.fileSizeInBytes ?? 0) > 0)
    }

}
