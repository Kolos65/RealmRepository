//
//  Detachable.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift

public protocol Detachable {
    init(detaching model: Self)
}

extension Detachable {
    public func detached() -> Self {
        type(of: self).init(detaching: self)
    }
}

extension List: Detachable where Element: Detachable {
    public convenience init(detaching model: List<Element>) {
        self.init()
        append(objectsIn: model.map { $0.detached() })
    }
}

extension MutableSet: Detachable where Element: Detachable {
    public convenience init(detaching model: MutableSet<Element>) {
        self.init()
        insert(objectsIn: map { $0.detached() })
    }
}

extension Map: Detachable where Value: Detachable {
    public convenience init(detaching model: Map<Key, Value>) {
        self.init()
        forEach { updateValue($0.value.detached(), forKey: $0.key) }
    }
}
