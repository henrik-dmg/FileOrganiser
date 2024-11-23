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
        let attributes = try XCTUnwrap(try handler.resourceValues(of: sourceURL))

        XCTAssertTrue(attributes.isRegularFileOrPackage)
        XCTAssertTrue((attributes.fileSizeInBytes ?? 0) > 0)
    }

    func testFileHandler_EnumeratesDirectory() throws {
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
        try "some-content".write(to: targetURL, atomically: true, encoding: .utf8)

        var enumeratedFiles = Set<String>()

        let handler = FileHandler()
        try handler.contentsOfDirectory(
            at: temporaryDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles, .producesRelativePathURLs],
            shouldSoftFail: false
        ) { url in
            enumeratedFiles.insert(url.relativePath)
        } softFailHandler: { error in
            XCTFail(error.localizedDescription)
        }

        XCTAssertEqual(enumeratedFiles.count, 4)
        XCTAssertEqual(enumeratedFiles, Set(["target", "target/text.txt", "source", "source/text.txt"]))
    }

    func testFileHandler_CantEnumerateDirectory() throws {
        let nonExistingDirectory = URL(filePath: "some-volume/that/does/not/exist")
            .appendingPathComponent("some-random-subfolder", conformingTo: .folder)
            .appendingPathComponent("non-existing", conformingTo: .folder)

        let handler = FileHandler()
        XCTAssertThrowsError(
            try handler.contentsOfDirectory(
                at: nonExistingDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .producesRelativePathURLs],
                shouldSoftFail: false
            ) { url in
                XCTFail("Should not call process handler")
            } softFailHandler: { error in
                XCTFail(error.localizedDescription)
            }
        )
    }

    func testFileHandler_ShouldSoftFail() throws {
        let sourceURL =
            temporaryDirectory
            .appendingPathComponent("source", conformingTo: .folder)
            .appendingPathComponent("text.txt", conformingTo: .text)

        try FileManager.default.createDirectory(at: sourceURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "some-content".write(to: sourceURL, atomically: true, encoding: .utf8)

        var hasThrownError = false

        let handler = FileHandler()
        try handler.contentsOfDirectory(
            at: temporaryDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles, .producesRelativePathURLs],
            shouldSoftFail: true
        ) { url in
            throw NSError(domain: "dev.panhans.FileOrganiserKitTests", code: 1000)
        } softFailHandler: { error in
            hasThrownError = true
        }

        XCTAssertTrue(hasThrownError)
    }

}
