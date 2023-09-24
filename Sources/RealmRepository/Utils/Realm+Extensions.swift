//
//  Realm+Extensions.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift
import Foundation

extension Results where Element: Object, Element: Detachable {
    var asArray: [Element] { Array(self) }
    func asDetachedArray() -> [Element] {
        asArray.map { $0.detached() }
    }
}

extension Object {
    var primaryKey: Any? {
        guard let property = objectSchema.primaryKeyProperty else { return nil }
        return value(forKey: property.name)
    }
}
