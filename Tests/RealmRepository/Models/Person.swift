//
//  Person.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift
import RealmRepository

@DataModel
final class Person: Object {
    @Persisted(primaryKey: true)
    var id = UUID()

    @Persisted var name = ""
    @Persisted var colors = List<String>()
    @Persisted var dogs: List<Dog>

    static var random: Person {
        let person = Person()
        person.id = UUID()
        person.name = ["Peter", "John", "Jake"].randomElement() ?? "Thomas"
        person.dogs = List<Dog>()
        person.dogs.append(objectsIn: [Dog.random, Dog.random])
        person.colors = List<String>()
        person.colors.append(objectsIn: ["red", "green", "blue"])
        return person
    }

    func valueEquals(with person: Person) -> Bool {
        id == person.id
        && name == person.name
        && dogs.elementsEqual(person.dogs, by: { $0.valueEquals(with: $1) })
        && colors.elementsEqual(person.colors, by: { $0 == $1 })
    }
}
