import Foundation
import XCTest

@testable import FileOrganiserKit

final class DateExtensionTests: XCTestCase {

    func testYearStrategy() throws {
        let date1 = try Date.make(year: 2024, month: 1, day: 1)
        let path1 = date1.path(for: .year)
        XCTAssertEqual(path1, "2024")

        // Just to be sure :D
        let date2 = try Date.make(year: 700, month: 1, day: 1)
        let path2 = date2.path(for: .year)
        XCTAssertEqual(path2, "0700")
    }

    func testMonthStrategy() throws {
        let date1 = try Date.make(year: 2024, month: 8, day: 1)
        let path1 = date1.path(for: .month)
        XCTAssertEqual(path1, "2024/08")

        let date2 = try Date.make(year: 2024, month: 12, day: 1)
        let path2 = date2.path(for: .month)
        XCTAssertEqual(path2, "2024/12")
    }

    func testDayStrategy() throws {
        let date1 = try Date.make(year: 2024, month: 4, day: 1)
        let path1 = date1.path(for: .day)
        XCTAssertEqual(path1, "2024/04/2024-04-01")

        let date2 = try Date.make(year: 2024, month: 12, day: 31)
        let path2 = date2.path(for: .day)
        XCTAssertEqual(path2, "2024/12/2024-12-31")
    }

}
