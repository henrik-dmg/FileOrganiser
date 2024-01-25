import Foundation
import XCTest

@testable import FileOrganiserKit

class FakeFileHandler: FileHandlerProtocol {

    var doesFileExistHandler: ((URL) -> Bool)?
    var resourceValuesHandler: ((URL) throws -> FileAttributes?)?
    var copyItemHandler: ((URL, URL) throws -> Void)?
    var moveItemHandler: ((URL, URL) throws -> Void)?
    var createDirectoryHandler: ((URL) throws -> Void)?
    var fakeContentsOfDirectory: [URL]?

    func doesFileExist(at url: URL) -> Bool {
        guard let doesFileExistHandler else {
            XCTFail("doesFileExistHandler should be set")
            return false
        }
        return doesFileExistHandler(url)
    }

    func resourceValues(of url: URL, useExifMetadataIfPossible: Bool) throws -> FileAttributes? {
        guard let resourceValuesHandler else {
            XCTFail("resourceValuesHandler should be set")
            return nil
        }
        return try resourceValuesHandler(url)
    }

    func copyItem(at source: URL, to target: URL) throws {
        guard let copyItemHandler else {
            XCTFail("copyItemHandler should be set")
            return
        }
        try copyItemHandler(source, target)
    }

    func moveItem(at source: URL, to target: URL) throws {
        guard let moveItemHandler else {
            XCTFail("moveItemHandler should be set")
            return
        }
        try moveItemHandler(source, target)
    }

    func createDirectory(at url: URL) throws {
        guard let createDirectoryHandler else {
            XCTFail("createDirectoryHandler should be set")
            return
        }
        try createDirectoryHandler(url)
    }

    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions,
        shouldSoftFail: Bool,
        callback: (URL) throws -> Void,
        softFailCallback: (Error) -> Void
    ) throws {
        guard let fakeContentsOfDirectory else {
            XCTFail("fakeContentsOfDirectory should be set")
            return
        }
        for url in fakeContentsOfDirectory {
            try callback(url)
        }
    }

}
