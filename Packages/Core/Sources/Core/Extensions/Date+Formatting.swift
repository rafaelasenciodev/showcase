import Foundation

public extension Date {
    var articleFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}
