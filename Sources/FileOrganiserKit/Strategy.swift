import Foundation

public enum DateGroupingStrategy: String, Codable, CaseIterable {
    case year, month, day
}

public enum FileHandlingStrategy: String, Codable {
    case move, copy
}
