import Foundation

protocol VerbosePrinteable {

    var verbose: Bool { get }

}

extension VerbosePrinteable {

    func printVerbose(_ args: Any...) {
        guard verbose else {
            return
        }

        let printString = args.map {
            String(describing: $0)
        }
        print(printString.joined(separator: " "))
    }

}
