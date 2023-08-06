//
//  User.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation

struct User: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var age: Int
    var email: String
}

extension User {
    static var random: User {
        let name = ["John", "Sara", "Peter", "Adam"].randomElement()!
        return User(
            name: name,
            age: Int.random(in: (0...99)),
            email: name + "@example.com"
        )
    }
}
