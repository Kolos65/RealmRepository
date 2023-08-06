//
//  RealmStorageImpl.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift
import Foundation

@RealmActor
public class RealmStorageImpl {

    // MARK: - Constants

    private enum Constants {
        static let schemaVersion: UInt64 = 1
        static let realmExtension = ".realm"
        static let postfixKey = "_db_postfix"
        static let metaFileExtensions = ["lock", "note", "management"]
    }

    // MARK: - Private properties

    private var realmInstance: Realm?

    // MARK: - Init

    public nonisolated init() {}
}

// MARK: - RealmStorage

extension RealmStorageImpl: RealmStorageContext {
    public func realm() throws -> Realm {
        guard let realmInstance else {
            throw RealmStorageError.databaseNotFound
        }
        return realmInstance
    }

    public func delete(name: String) async throws {
        realmInstance?.invalidate()
        let realmPath = path(for: name)
        deletePostfix(for: name)
        guard FileManager.default.fileExists(atPath: realmPath.relativePath) else { return }
        let metaFiles = Constants.metaFileExtensions.map { realmPath.appendingPathExtension($0) }
        for path in [realmPath] + metaFiles {
            try FileManager.default.removeItem(at: path)
        }
    }

    public func connect(to name: String, password: String?, salt: String?) async throws {
        let configuration = try realmConfiguration(for: name, password: password, salt: salt)
        realmInstance = try await Realm(configuration: configuration, actor: RealmActor.shared)
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var realmPath = path(for: name)
        try realmPath.setResourceValues(resourceValues)
    }
}

// MARK: - Helpers

extension RealmStorageImpl {
    private func realmConfiguration(for name: String, password: String?, salt: String?) throws -> Realm.Configuration {
        var key: Data?
        if let password {
            key = try generateKey(from: password, salt: salt)
        }
        return Realm.Configuration(
            fileURL: path(for: name),
            encryptionKey: key,
            readOnly: false,
            schemaVersion: Constants.schemaVersion,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true
        )
    }

    private func path(for name: String) -> URL {
        let postfix = getPostfix(for: name) ?? createPostfix(for: name)
        let fileName = name + postfix + Constants.realmExtension
        return documentURLForFile(with: fileName)
    }

    private func getPostfix(for name: String) -> String? {
        UserDefaults.standard.string(forKey: name + Constants.postfixKey)
    }

    private func createPostfix(for name: String) -> String {
        let postfix = UUID().uuidString
        UserDefaults.standard.set(postfix, forKey: name + Constants.postfixKey)
        return postfix
    }

    private func deletePostfix(for name: String) {
        UserDefaults.standard.removeObject(forKey: name + Constants.postfixKey)
    }

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func documentURLForFile(with name: String) -> URL {
        documentsURL.appendingPathComponent(name)
    }
}
