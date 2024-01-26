import Foundation
import XCTest

@testable import FileOrganiserKit

final class PrinterTests: TemporaryFileTests {

    func testPrinter_WritesToRegularOutput() throws {
        let printer = try Printer.makeFake(outputFileName: "test_output")
        printer.writeDefault("test-string\nanother line")

        let url = temporaryDirectory.appendingPathComponent("test_output", conformingTo: .plainText)
        let contents = try String(contentsOf: url)
        XCTAssertEqual(contents, "test-string\nanother line\n")
    }

    func testPrinter_WritesToErrorOutput() throws {
        let printer = try Printer.makeFake(errorOutputFileName: "test_error_output")
        printer.writeError("test-string\nanother line")

        let url = temporaryDirectory.appendingPathComponent("test_error_output", conformingTo: .plainText)
        let contents = try String(contentsOf: url)
        XCTAssertEqual(contents, "test-string\nanother line\n")
    }

}
