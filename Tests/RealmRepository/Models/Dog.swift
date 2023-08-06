//
//  Dog.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift

class Dog: Object {
    @Persisted(primaryKey: true)
    var id = UUID()

    @Persisted var name = ""
    @Persisted var age = 0
    @Persisted var color = ""
    @Persisted var currentCity = ""

    static var random: Dog {
        let dog = Dog()
        dog.id = UUID()
        dog.name = ["Lucky", "Bucky", "Ducky"].randomElement() ?? "Sucky"
        dog.age = [1, 2, 3, 4, 5].randomElement() ?? 6
        dog.color = ["red", "green", "blue"].randomElement() ?? "black"
        dog.currentCity = ["city1", "city2", "city3"].randomElement() ?? "city4"
        return dog
    }

    func valueEquals(with dog: Dog) -> Bool {
        id == dog.id
        && name == dog.name
        && age == dog.age
        && color == dog.color
        && currentCity == dog.currentCity
    }
}
