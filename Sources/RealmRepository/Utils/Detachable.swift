//
//  Detachable.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift

public protocol Detachable {
    func detached() -> Self
}

extension Object: Detachable {
    public func detached() -> Self {
        let detached = type(of: self).init()
        objectSchema.properties.forEach { property in
            let key = property.name
            guard let value = value(forKey: key) else { return }
            guard let value = value as? Detachable else {
                detached.setValue(value, forKey: key)
                return
            }
            detached.setValue(value.detached(), forKey: key)
        }
        return detached
    }
}

extension EmbeddedObject: Detachable {
    public func detached() -> Self {
        let detached = type(of: self).init()
        objectSchema.properties.forEach { property in
            let key = property.name
            guard let value = value(forKey: key) else { return }
            guard let value = value as? Detachable else {
                detached.setValue(value, forKey: key)
                return
            }
            detached.setValue(value.detached(), forKey: key)
        }
        return detached
    }
}

extension List: Detachable {
    public func detached() -> Self {
        let result = type(of: self).init()
        forEach {
            let element = detach(element: $0)
            result.append(element)
        }
        return result
    }

    func detach(element: Element) -> Element {
        let detachable = element as? Detachable
        let detached = detachable?.detached() as? Element
        return detached ?? element
    }
}

extension MutableSet: Detachable {
    public func detached() -> Self {
        let result = type(of: self).init()
        forEach {
            let element = detach(element: $0)
            result.insert(element)
        }
        return result
    }

    func detach(element: Element) -> Element {
        let detachable = element as? Detachable
        let detached = detachable?.detached() as? Element
        return detached ?? element
    }
}

extension Map: Detachable {
    public func detached() -> Self {
        let result = type(of: self).init()
        forEach {
            let value = detach(value: $0.value)
            result.updateValue(value, forKey: $0.key)
        }
        return result
    }

    func detach(value: Value) -> Value {
        let detachable = value as? Detachable
        let detached = detachable?.detached() as? Value
        return detached ?? value
    }
}
