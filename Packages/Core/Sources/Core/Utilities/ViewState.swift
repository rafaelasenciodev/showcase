import Foundation

public enum ViewState<T: Sendable>: Sendable, Equatable where T: Equatable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)

    public static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            true
        case let (.loaded(l), .loaded(r)):
            l == r
        case let (.error(l), .error(r)):
            l == r
        default:
            false
        }
    }
}
