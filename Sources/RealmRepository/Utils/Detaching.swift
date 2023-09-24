//
//  Detaching.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 08..
//

import Foundation
import RealmSwift

public protocol Detaching {
    func detach<Value>(_ value: Value) -> Value
}

extension Detaching {
    public func detach<Value>(_ value: Value) -> Value { value }
    public func detach<Value>(_ value: Value) -> Value where Value: Detachable { value.detached() }
}

extension Object: Detaching {}
extension EmbeddedObject: Detaching {}
