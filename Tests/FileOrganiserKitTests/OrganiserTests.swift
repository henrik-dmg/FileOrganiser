import Foundation
import XCTest

@testable import FileOrganiserKit

final class OrganiserTests: XCTestCase {

    // MARK: - Nested Types

    struct FakeFileStructure {
        let sourceURL: URL
        let subDirectoryURL: URL
        let destinationURL: URL
        let imageURL: URL
        let textFileURL: URL
    }

    // MARK: - Tests

    func testOrganiser_OnlyCopies_WhenAskedToCopy() throws {
        let fakeFileStructure = makeFakeFileStructure()
        let fakeImageCreationDate = try Date.make(year: 2024, month: 1, day: 19)

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL
        ]
        fakeFileHandler.copyItemHandler = { sourceURL, _ in
            XCTAssertEqual(sourceURL.relativePath, fakeFileStructure.imageURL.relativePath)
        }
        fakeFileHandler.moveItemHandler = { _, _ in
            XCTFail("Move handler should not be called")
        }
        fakeFileHandler.doesFileExistHandler = { url in
            false
        }
        fakeFileHandler.resourceValuesHandler = { _ in
            FileAttributes(fileSizeInBytes: 100, creationDate: fakeImageCreationDate, isRegularFileOrPackage: true)
        }
        fakeFileHandler.createDirectoryHandler = { url in
            XCTAssertEqual(url.relativePath, fakeFileStructure.destinationURL.relativePath + "/" + fakeImageCreationDate.path(for: .year))
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            fileStrategy: .copy,
            dateStrategy: .year,
            dryRun: false,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 1)
        XCTAssertEqual(result.filesWritten, 1)
    }

    func testOrganiser_OnlyMoves_WhenAskedToMove() throws {
        let fakeFileStructure = makeFakeFileStructure()
        let fakeImageCreationDate = try Date.make(year: 2024, month: 1, day: 19)

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL
        ]
        fakeFileHandler.copyItemHandler = { _, _ in
            XCTFail("Copy handler should not be called")
        }
        fakeFileHandler.moveItemHandler = { sourceURL, _ in
            XCTAssertEqual(sourceURL.relativePath, fakeFileStructure.imageURL.relativePath)
        }
        fakeFileHandler.doesFileExistHandler = { url in
            false
        }
        fakeFileHandler.resourceValuesHandler = { _ in
            FileAttributes(fileSizeInBytes: 100, creationDate: fakeImageCreationDate, isRegularFileOrPackage: true)
        }
        fakeFileHandler.createDirectoryHandler = { url in
            XCTAssertEqual(url.relativePath, fakeFileStructure.destinationURL.relativePath + "/" + fakeImageCreationDate.path(for: .year))
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            fileStrategy: .move,
            dateStrategy: .year,
            dryRun: false,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 1)
        XCTAssertEqual(result.filesWritten, 1)
    }

    func testOrganiser_SkipsExistingFiles() throws {
        let fakeFileStructure = makeFakeFileStructure()

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL
        ]
        fakeFileHandler.moveItemHandler = { sourceURL, _ in
            XCTAssertEqual(sourceURL.relativePath, fakeFileStructure.imageURL.relativePath)
        }
        fakeFileHandler.doesFileExistHandler = { url in
            true
        }
        fakeFileHandler.resourceValuesHandler = { _ in
            FileAttributes(fileSizeInBytes: 100, creationDate: .now, isRegularFileOrPackage: true)
        }
        fakeFileHandler.createDirectoryHandler = { url in
            XCTFail("Should not attempt to create any directories")
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            fileStrategy: .move,
            dateStrategy: .year,
            dryRun: false,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 1)
        XCTAssertEqual(result.filesWritten, 0)
        XCTAssertEqual(result.filesSkipped, 1)
    }

    func testOrganiser_RespectsDryRun_AndTouchesNoFiles() throws {
        let fakeFileStructure = makeFakeFileStructure()

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL,
            fakeFileStructure.textFileURL,
            fakeFileStructure.subDirectoryURL,
        ]
        fakeFileHandler.resourceValuesHandler = { url in
            FileAttributes(
                fileSizeInBytes: 100,
                creationDate: .now,
                isRegularFileOrPackage: url == fakeFileStructure.imageURL || url == fakeFileStructure.textFileURL
            )
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            fileStrategy: .move,
            dateStrategy: .year,
            dryRun: true,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 2)
        XCTAssertEqual(result.filesWritten, 0)
        XCTAssertEqual(result.filesSkipped, 0)
    }

    func testOrganiser_DoesntTouchNonRegularFiles() throws {
        let fakeFileStructure = makeFakeFileStructure()

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL,
            fakeFileStructure.textFileURL,
        ]
        fakeFileHandler.resourceValuesHandler = { _ in
            nil
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            fileStrategy: .move,
            dateStrategy: .year,
            dryRun: true,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 0)
        XCTAssertEqual(result.filesWritten, 0)
        XCTAssertEqual(result.filesSkipped, 0)
    }

    func testOrganiser_GlobPattern_MatchesImageFile_ButNotTextFile() throws {
        let fakeFileStructure = makeFakeFileStructure()
        let fakeImageCreationDate = try Date.make(year: 2024, month: 1, day: 19)

        let fakeFileHandler = FakeFileHandler()
        fakeFileHandler.fakeContentsOfDirectory = [
            fakeFileStructure.imageURL,
            fakeFileStructure.textFileURL,
        ]
        fakeFileHandler.copyItemHandler = { sourceURL, _ in
            XCTAssertEqual(sourceURL.relativePath, fakeFileStructure.imageURL.relativePath)
        }
        fakeFileHandler.doesFileExistHandler = { url in
            false
        }
        fakeFileHandler.resourceValuesHandler = { _ in
            FileAttributes(fileSizeInBytes: 100, creationDate: fakeImageCreationDate, isRegularFileOrPackage: true)
        }
        fakeFileHandler.createDirectoryHandler = { url in
            XCTAssertEqual(url.relativePath, fakeFileStructure.destinationURL.relativePath + "/" + fakeImageCreationDate.path(for: .year))
        }

        let result = try runOrganiser(
            fileStructure: fakeFileStructure,
            glob: "**/*.jpeg",
            fileStrategy: .copy,
            dateStrategy: .year,
            dryRun: false,
            fileHandler: fakeFileHandler
        )
        XCTAssertEqual(result.filesProcessed, 2)
        XCTAssertEqual(result.filesWritten, 1)
        XCTAssertEqual(result.filesSkipped, 1)
    }

    func testOrganiser_ThrowsIfGlobPatternIsInvalid() throws {
        let fakeFileStructure = makeFakeFileStructure()
        let fakeFileHandler = FakeFileHandler()

        XCTAssertThrowsError(
            try runOrganiser(
                fileStructure: fakeFileStructure,
                glob: "{.",
                fileStrategy: .copy,
                dateStrategy: .year,
                dryRun: false,
                fileHandler: fakeFileHandler
            )
        )
    }

    // MARK: - Helpers

    private func makeFakeFileStructure() -> FakeFileStructure {
        let fakeSourceURL = URL(filePath: "/some/directory")
        let fakeSubDirectoryURL = fakeSourceURL.appendingPathComponent("subdirectory")
        let fakeDestinationURL = URL(filePath: "/some/other-directory")
        let fakeImageURL = fakeSourceURL.appendingPathComponent("mypicture", conformingTo: .jpeg)
        let fakeTextURL = fakeSubDirectoryURL.appendingPathComponent("token", conformingTo: .text)
        return FakeFileStructure(
            sourceURL: fakeSourceURL,
            subDirectoryURL: fakeSubDirectoryURL,
            destinationURL: fakeDestinationURL,
            imageURL: fakeImageURL,
            textFileURL: fakeTextURL
        )
    }

    @discardableResult
    private func runOrganiser(
        fileStructure: FakeFileStructure,
        glob: String? = nil,
        fileStrategy: FileHandlingStrategy,
        dateStrategy: DateGroupingStrategy,
        dryRun: Bool,
        fileHandler: FileHandlerProtocol,
        shouldSoftFail: Bool = false
    ) throws -> Organiser.DirectoryProcessingResult {
        let logger = Logger(options: [.verbose, .skipSummary], printer: try Printer.makeFake())
        let organiser = Organiser(fileHandler: fileHandler, logger: logger)
        return try organiser.processWithResult(
            sourceURL: fileStructure.sourceURL,
            destinationURL: fileStructure.destinationURL,
            globPattern: glob,
            fileStrategy: fileStrategy,
            dateStrategy: dateStrategy,
            dryRun: dryRun,
            shouldSoftFail: shouldSoftFail
        )
    }

}
