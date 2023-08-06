//
//  PrivateStorageContext.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift
import Foundation

/// An error type representing potential failures when interacting with Realm storage.
public enum RealmStorageError: Error {
    case databaseNotFound
}

 enum RealmStorageDefaults {
    static let name = "Public"
}

public enum RealmStorage {
    private static var defaultStorage: RealmStorageContext?
    public static var `default`: RealmStorageContext {
        guard let defaultStorage else {
            let instance = RealmStorageImpl()
            defaultStorage = instance
            return instance
        }
        return defaultStorage
    }
}

/// A protocol that encapsulates the operations related to the Realm database storage context.
/// Conforming types can implement methods to handle the creation, connection, and deletion of Realm database instances.
@RealmActor
public protocol RealmStorageContext {
    /// Returns a Realm instance.
    ///
    /// - Returns: A `Realm` instance.
    /// - Throws: If there's an error while getting the `Realm` instance.
    func realm() throws -> Realm

    /// Connects to a Realm database instance with the specified name, password, and salt.
    ///
    /// - Parameters:
    ///   - name: The name of the Realm database.
    ///   - password: The password for the Realm database, if used.
    ///   - salt: The salt for the password, if used.
    /// - Throws: If there's an error while connecting to the `Realm` database.
    func connect(to name: String, password: String?, salt: String?) async throws

    /// Deletes a Realm database instance with the specified name.
    ///
    /// - Parameter name: The name of the Realm database to be deleted.
    /// - Throws: If there's an error while deleting the `Realm` database.
    func delete(name: String) async throws
}

extension RealmStorageContext {

    /// Deletes the default Realm database.
    ///
    /// - Throws: If there's an error while deleting the default `Realm` database.
    public func delete() async throws {
        try await delete(name: RealmStorageDefaults.name)
    }

    /// Connects to the default Realm database instance.
    ///
    /// - Throws: If there's an error while connecting to the default `Realm` database.
    public func connect() async throws {
        try await connect(to: RealmStorageDefaults.name, password: nil, salt: nil)
    }

    /// Connects to a Realm database instance with the specified name and password.
    ///
    /// - Parameters:
    ///   - name: The name of the Realm database.
    ///   - password: The password for the Realm database.
    /// - Throws: If there's an error while connecting to the `Realm` database.
    public func connect(to name: String, password: String) async throws {
        try await connect(to: name, password: password, salt: nil)
    }
}
