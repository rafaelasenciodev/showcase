import Foundation

/// Marker protocol for the app composition root.
/// Concrete factory methods are implemented in the App target's `LiveDependencyContainer`.
public protocol DependencyContaining: AnyObject {}
