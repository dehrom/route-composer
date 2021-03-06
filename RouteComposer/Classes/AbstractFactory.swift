//
// Created by Eugene Kazaev on 30/07/2018.
//

import Foundation
import UIKit

/// Base protocol for all types of factories.
/// An instance that extends `AbstractFactory` builds a `UIViewController` that will later be
/// integrated into the stack by the `Router`
public protocol AbstractFactory {

    /// Type of `UIViewController` that `Factory` can build
    associatedtype ViewController: UIViewController

    /// `Context` to be passed into `UIViewController`
    associatedtype Context

    /// The `Router` will call it before the navigation process and if the `AbstractFactory` is not able to
    /// build a view controller it should throw an exception. (example: it has to build a product view
    //  controller but there is no product code in context)
    ///
    /// - Parameter context: A `Context` instance that is provided to the `Router`.
    /// - Throws: The `RoutingError` if the `Factory` cannot prepare to build a `UIViewController` instance
    ///   with the `Context` instance provided.
    mutating func prepare(with context: Context) throws

}
