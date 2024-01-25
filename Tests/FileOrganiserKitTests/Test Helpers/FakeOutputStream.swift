import Foundation
import XCTest

@testable import FileOrganiserKit

/// Fake logger to prevent spamming console output in tests
struct FakeOutputStream: TextOutputStream {

    private(set) var output = ""

    mutating func write(_ string: String) {
        output += string
    }

}
