//
//  PerformanceTests.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import XCTest
import Realm
import RealmSwift

@testable import RealmRepository

class PerformanceTests: XCTestCase {
    private var storage: RealmStorageContext!
    private var repository: Repository<Person>!
    private let queue = DispatchQueue(label: "RealmQueue")
    private var realm: Realm!

    override func setUp() async throws {
        storage = RealmStorageImpl()
        try await storage.delete()
        try await storage.connect()
        repository = Repository<Person>(storage: storage)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent("RealmBaseLine.realm")
        try? FileManager.default.removeItem(at: url)
        let configuration = Realm.Configuration(
            fileURL: url,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: 1,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true
        )
        try queue.sync {
            realm = try Realm(configuration: configuration, queue: queue)
        }
    }

    func testWriteBaseline() throws {
        queue.sync {
            measure {
                do {
                    let people = (0..<100_000).map { _ in Person.random }
                    try realm.write {
                        realm.add(people, update: .modified)
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }

    func testWrites() async throws {
        await Task(priority: .high) { @RealmActor in
            measure {
                do {
                    let people = (0..<100_000).map { _ in Person.random }
                    try repository.upsert(people)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }.value
    }
}

