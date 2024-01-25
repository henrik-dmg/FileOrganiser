import Foundation
import XCTest
import AppKit

@testable import FileOrganiserKit

final class ExifParserTests: XCTestCase {

    // MARK: - Tests

    func testParser_CanReadImage() throws {
        let imageURL = try makeExifImageURL()
        let metadata = try ExifParser.exifMetadata(ofFile: imageURL)

        let dateComponents = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: metadata.captureDate)
        XCTAssertEqual(dateComponents.year, 2023)
        XCTAssertEqual(dateComponents.month, 4)
        XCTAssertEqual(dateComponents.day, 13)
    }

    func testParser_CantParsePlainImage() throws {
        let imageURL = try makePlainImageURL()
        do {
            _ = try ExifParser.exifMetadata(ofFile: imageURL)
        } catch {
            guard let parserError = error as? ExifParser.ParserError else {
                throw error
            }
            switch parserError.reason {
            case .noExifProperties, .noCaptureDate:
                break
            case .notAnImage, .unparsableCaptureDate:
                throw parserError
            }
        }
    }

    // MARK: - Helpers

    private func makePlainImageURL() throws -> URL {
        try XCTUnwrap(Bundle.module.url(forResource: "test_image", withExtension: "jpg", subdirectory: "Resources"))
    }

    private func makeExifImageURL() throws -> URL {
        try XCTUnwrap(Bundle.module.url(forResource: "test_image_with_exif", withExtension: "jpg", subdirectory: "Resources"))
    }

}
