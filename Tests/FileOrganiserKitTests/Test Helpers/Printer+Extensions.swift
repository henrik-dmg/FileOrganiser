import Foundation

@testable import FileOrganiserKit

extension Printer {

    static func makeFake(outputFileName: String = "output", errorOutputFileName: String = "error_output") throws -> Printer {
        let tempDirectory = try FileManager.default.hp_makeTemporaryDirectory()
        let fakeOutput = tempDirectory.appendingPathComponent(outputFileName, conformingTo: .plainText)
        let fakeErrorOutput = tempDirectory.appendingPathComponent(errorOutputFileName, conformingTo: .plainText)
        if FileManager.default.fileExists(atPath: fakeOutput.path) {
            // swift-format-ignore
            try "".data(using: .utf8)!.write(to: fakeOutput)
        } else {
            FileManager.default.createFile(atPath: fakeOutput.path, contents: nil)
        }

        if FileManager.default.fileExists(atPath: fakeErrorOutput.path) {
            // swift-format-ignore
            try "".data(using: .utf8)!.write(to: fakeErrorOutput)
        } else {
            FileManager.default.createFile(atPath: fakeErrorOutput.path, contents: nil)
        }

        let fakeFileHandle = try FileHandle(forWritingTo: fakeOutput)
        let fakeErrorFileHandle = try FileHandle(forWritingTo: fakeErrorOutput)
        return Printer(outputFileHandle: fakeFileHandle, errorFileHandle: fakeErrorFileHandle)
    }

}
