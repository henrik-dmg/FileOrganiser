import Foundation

extension Date {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    func path(for strategy: DateGroupingStrategy) -> String {
        switch strategy {
        case .year:
            let formatter = Date.formatter
            formatter.dateFormat = "yyyy"
            return formatter.string(from: self)
        case .month:
            let formatter = Date.formatter
            formatter.dateFormat = "yyyy/MM"
            return formatter.string(from: self)
        case .day:
            let formatter = Date.formatter
            formatter.dateFormat = "yyyy/MM/yyyy-MM-dd"
            return formatter.string(from: self)
        }
    }

}
