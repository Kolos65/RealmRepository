//
//  RepositoryUnitTests.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import XCTest
import Realm
import RealmSwift

@testable import RealmRepository

class RepositoryUnitTests: XCTestCase {
    private var sut: Repository<Person>!
    private var storage: RealmStorageContext!

    override func setUp() async throws {
        storage = RealmStorageImpl()
        try await storage.delete()
        try await storage.connect()
        sut = Repository<Person>(storage: storage)
    }

    @RealmActor
    private func withRealm(_ block: @escaping (Realm) throws -> Void) throws {
        let realm = try storage.realm()
        try block(realm)
    }

    func testInsertModel() async throws {
        let person = Person.random
        try await sut.insert(person)
        try await withRealm { realm in
            let saved = realm.object(ofType: Person.self, forPrimaryKey: person.id)
            XCTAssertNotNil(saved)
        }
    }

    func testInsertModels() async throws {
        let people = [Person.random, Person.random, Person.random]
        try await sut.insert(people)
        try await withRealm { realm in
            people.map(\.id).forEach { key in
                XCTAssertNotNil(realm.object(ofType: Person.self, forPrimaryKey: key))
            }
        }
    }

    func testGetModels() async throws {
        let people = [Person.random, Person.random, Person.random]
        try await withRealm { realm in
            try realm.write { realm.add(people) }
        }
        let saved = try await sut.get()
        try await withRealm { _ in
            let gotAll = people.allSatisfy { person in
                saved.contains { object in
                    object.valueEquals(with: person)
                }
            }
            XCTAssertTrue(gotAll)
        }
    }

    func testGetForKey() async throws {
        let person = Person.random
        let key = person.id
        try await withRealm { realm in
            try realm.write { realm.add(person) }
        }
        let saved = try await sut.get(for: key)
        try await withRealm { _ in
            XCTAssertTrue(saved.valueEquals(with: person))
        }
    }

    func testUpsertNewModel() async throws {
        let person = Person.random
        try await sut.upsert(person)
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertTrue(person.valueEquals(with: saved))
        }
    }

    func testUpsertExistingModel() async throws {
        let person = Person.random
        let oldName = person.name
        try await sut.insert(person)
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, oldName)
        }
        let newName = UUID().uuidString
        person.name = newName
        try await sut.upsert(person)
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, newName)
        }
    }

    func testUpsertNewModels() async throws {
        let people = [Person.random, Person.random, Person.random]
        try await sut.upsert(people)
        try await withRealm { realm in
            people.map(\.id).forEach { key in
                XCTAssertNotNil(realm.object(ofType: Person.self, forPrimaryKey: key))
            }
        }
    }

    func testUpsertExistingModels() async throws {
        let people = [Person.random, Person.random, Person.random]
        let oldNames = people.map(\.name)
        try await sut.insert(people)
        try await withRealm { realm in
            let savedNames = realm.objects(Person.self).map(\.name)
            XCTAssertEqual(Set(oldNames), Set(savedNames))
        }
        let newName = UUID().uuidString
        people.forEach { $0.name = newName }
        try await sut.upsert(people)
        try await withRealm { realm in
            let savedNames = realm.objects(Person.self).map(\.name)
            savedNames.forEach {
                XCTAssertEqual($0, newName)
            }
        }
    }

    func testUpdateModel() async throws {
        let person = Person.random
        let oldName = person.name
        try await sut.insert(person)
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, oldName)
        }
        let newName = UUID().uuidString
        try await sut.update(person) {
            $0.name = newName
        }
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, newName)
        }
    }

    func testUpdateModelByKey() async throws {
        let person = Person.random
        let oldName = person.name
        try await sut.insert(person)
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, oldName)
        }
        let newName = UUID().uuidString
        try await sut.update(person.id) {
            $0.name = newName
        }
        try await withRealm { realm in
            let saved = try XCTUnwrap(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            XCTAssertEqual(saved.name, newName)
        }
    }

    func testRemoveModel() async throws {
        let person = Person.random
        let detached = person.detached()
        try await withRealm { realm in
            try realm.write { realm.add(person) }
        }
        try await sut.remove(detached)
        try await withRealm { realm in
            XCTAssertNil(realm.object(ofType: Person.self, forPrimaryKey: detached.id))
        }
    }

    func testRemoveModelByKey() async throws {
        let person = Person.random
        let detached = person.detached()
        try await withRealm { realm in
            try realm.write { realm.add(person) }
        }
        try await sut.remove(detached.id)
        try await withRealm { realm in
            XCTAssertNil(realm.object(ofType: Person.self, forPrimaryKey: detached.id))
        }
    }

    func testRemoveModels() async throws {
        let people1 = [Person.random, Person.random]
        let people2 = [Person.random, Person.random]
        let detached1 = people1.map { $0.detached() }
        let detached2 = people2.map { $0.detached() }
        try await withRealm { realm in
            try realm.write {
                realm.add(people1)
                realm.add(people2)
            }
        }
        try await sut.remove(detached1)
        try await withRealm { realm in
            detached1.forEach { person in
                XCTAssertNil(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            }
            detached2.forEach { person in
                XCTAssertNotNil(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            }
        }
    }

    func testRemoveAll() async throws {
        let people = [Person.random, Person.random, Person.random]
        try await withRealm { realm in
            try realm.write { realm.add(people) }
        }
        try await sut.removeAll()
        try await withRealm { realm in
            let objects = realm.objects(Person.self)
            XCTAssertTrue(objects.isEmpty)
        }
    }

    func testReplaceAll() async throws {
        let people = [Person.random, Person.random, Person.random]
        let newPeople = [Person.random, Person.random, Person.random]
        let detachedNewPeople = newPeople.map { $0.detached() }
        try await withRealm { realm in
            try realm.write { realm.add(people) }
        }
        try await sut.replaceAll(with: newPeople)
        try await withRealm { realm in
            detachedNewPeople.forEach { person in
                XCTAssertNotNil(realm.object(ofType: Person.self, forPrimaryKey: person.id))
            }
        }
    }
}

