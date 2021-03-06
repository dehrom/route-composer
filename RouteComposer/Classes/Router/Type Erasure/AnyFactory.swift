//
// Created by Eugene Kazaev on 14/02/2018.
//

import Foundation
import UIKit

protocol AnyFactory {

    var action: AnyAction { get }

    mutating func prepare(with context: Any?) throws

    func build(with context: Any?) throws -> UIViewController

    mutating func scrapeChildren(from factories: [AnyFactory]) throws -> [AnyFactory]

}

protocol AnyFactoryBox: AnyFactory {

    associatedtype FactoryType: AbstractFactory

    static func box(for factory: FactoryType?, action: AnyAction) -> AnyFactory?

    var factory: FactoryType { get set }

    init(_ factory: FactoryType, action: AnyAction)

}

extension AnyFactoryBox where Self: AnyFactory {

    static func box(for factory: FactoryType?, action: AnyAction) -> AnyFactory? {
        if factory as? NilEntity != nil {
            return nil
        } else if let factory = factory {
            return Self(factory, action: action)
        }
        return nil
    }

    mutating func prepare(with context: Any?) throws {
        guard let typedContext = Any?.some(context as Any) as? FactoryType.Context else {
            throw RoutingError.typeMismatch(FactoryType.Context.self, RoutingError.Context(debugDescription: "\(String(describing: factory.self)) does " +
                    "not accept \(String(describing: context.self)) as a context."))
        }
        return try factory.prepare(with: typedContext)
    }

    mutating func scrapeChildren(from factories: [AnyFactory]) throws -> [AnyFactory] {
        return factories
    }

}

extension AnyFactory where Self: CustomStringConvertible & AnyFactoryBox {

    var description: String {
        return String(describing: factory)
    }

}

struct FactoryBox<F: Factory>: AnyFactory, AnyFactoryBox, CustomStringConvertible {

    typealias FactoryType = F

    var factory: F

    let action: AnyAction

    init(_ factory: F, action: AnyAction) {
        self.factory = factory
        self.action = action
    }

    func build(with context: Any?) throws -> UIViewController {
        guard let typedContext = Any?.some(context as Any) as? FactoryType.Context else {
            throw RoutingError.typeMismatch(FactoryType.Context.self, RoutingError.Context(debugDescription: "\(String(describing: factory.self)) does " +
                    "not accept \(String(describing: context.self)) as a context."))
        }
        return try factory.build(with: typedContext)
    }

}

struct ContainerFactoryBox<F: ContainerFactory>: AnyFactory, AnyFactoryBox, CustomStringConvertible {

    typealias FactoryType = F

    var factory: FactoryType

    let action: AnyAction

    var children: [DelayedIntegrationFactory<FactoryType.Context>] = []

    init(_ factory: FactoryType, action: AnyAction) {
        self.factory = factory
        self.action = action
    }

    mutating func scrapeChildren(from factories: [AnyFactory]) throws -> [AnyFactory] {
        var otherFactories: [AnyFactory] = []
        self.children = factories.compactMap({ child -> DelayedIntegrationFactory<FactoryType.Context>? in
            guard child.action.embeddable else {
                otherFactories.append(child)
                return nil
            }
            return DelayedIntegrationFactory(child)
        })
        return otherFactories
    }

    func build(with context: Any?) throws -> UIViewController {
        guard let typedContext = Any?.some(context as Any) as? FactoryType.Context else {
            throw RoutingError.typeMismatch(FactoryType.Context.self, RoutingError.Context(debugDescription: "\(String(describing: factory.self)) does " +
                    "not accept \(String(describing: context.self)) as a context."))
        }
        return try factory.build(with: typedContext, integrating: ChildCoordinator(childFactories: children))
    }

}
