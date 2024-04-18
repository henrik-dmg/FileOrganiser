import Foundation

// Workaround class because print("something", to: &customOutputStream) does not work currently in debug mode
// More information: https://github.com/apple/swift/issues/71047
final class Printer {

    let outputFileHandle: FileHandle
    let errorFileHandle: FileHandle

    init(outputFileHandle: FileHandle, errorFileHandle: FileHandle) {
        self.outputFileHandle = outputFileHandle
        self.errorFileHandle = errorFileHandle
    }

    func writeDefault(_ string: String) {
        if let data = (string + "\n").data(using: .utf8) {
            outputFileHandle.write(data)
        }
    }

    func writeError(_ string: String) {
        if let data = (string + "\n").data(using: .utf8) {
            errorFileHandle.write(data)
        }
    }

}
