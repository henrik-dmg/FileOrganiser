import Foundation
import XCTest

extension Date {

    static func make(
        year: Int,
        month: Int,
        day: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return try XCTUnwrap(calendar.date(from: components), file: file, line: line)
    }

}
