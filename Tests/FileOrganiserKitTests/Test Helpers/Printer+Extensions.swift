import Foundation

@testable import FileOrganiserKit

extension Printer {

    static func makeFake() throws -> Printer {
        let fakeOutput = FileManager.default.temporaryDirectory.appendingPathComponent("FileOrganiserFakeOutput", conformingTo: .plainText)
        if FileManager.default.fileExists(atPath: fakeOutput.path) {
            // swift-format-ignore
            try "".data(using: .utf8)!.write(to: fakeOutput)
        } else {
            FileManager.default.createFile(atPath: fakeOutput.path, contents: nil)
        }

        let fakeFileHandle = try FileHandle(forWritingTo: fakeOutput)
        return Printer(outputFileHandle: fakeFileHandle, errorFileHandle: fakeFileHandle)
    }

}
