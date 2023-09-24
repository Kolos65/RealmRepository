//
//  Repository.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift

/// Defines the set of errors that can be thrown by `Repository` operations.
public enum RepositoryError: Error {
    case keyNotFound
    case objectNotFound
}

/// A generic class responsible for managing CRUD operations on Realm `Object` subclasses.
///
/// Repository ensures data consistency and thread safety by using a global actor called `@RealmActor` to synchronize database operations and create actor-confined `Realms`.
@RealmActor
public class Repository<Model: Object> where Model: Detachable {

    // MARK: - Internal properties

    let storage: RealmStorageContext

    // MARK: - Init

    /// Initializes a new repository with the specified storage.
    ///
    /// You should create and connect to a `RealmStorage` early in your app lifecycle and provide the storage to each `Repository` upon initialization. `RealmStorage` provides the Realm configuration and underlying realm instance to each repository.
    ///
    /// - Parameter storage: A `RealmStorage` instance that was previously set up.
    public nonisolated init(storage: RealmStorageContext = RealmStorage.default) {
        self.storage = storage
    }

    // MARK: - Create

    /// Inserts a single model into the Realm database.
    ///
    /// - Parameter model: The model to insert.
    /// - Throws: An `Error` if a model with the same primary key already exists.
    public func insert(_ model: Model) throws {
        let realm = try storage.realm()
        let detached = model.detached()
        try realm.write {
            realm.add(detached)
        }
    }

    /// Inserts an array of models into the Realm database.
    ///
    /// - Parameter models: The array of models to insert.
    /// - Throws: An `Error` if a model with the same primary key as any of the passed models already exists.
    public func insert(_ models: [Model]) throws {
        let realm = try storage.realm()
        let detached = models.map { $0.detached() }
        try realm.write {
            realm.add(detached)
        }
    }

    // MARK: - Read

    /// Fetches all the models from the `Repository`.
    ///
    /// - Returns: An array of models.
    public func get() throws -> [Model] {
        let realm = try storage.realm()
        let results = realm.objects(Model.self)
        return results.asDetachedArray()
    }

    /// Fetches a specific model by its primary key.
    ///
    /// - Parameter key: The primary key of the model to fetch.
    /// - Returns: The fetched model.
    /// - Throws: `RepositoryError.keyNotFound` if the model cannot be found.
    public func get<KeyType>(for key: KeyType) throws -> Model {
        let realm = try storage.realm()
        guard let result = realm.object(ofType: Model.self, forPrimaryKey: key) else {
            throw RepositoryError.keyNotFound
        }
        return result.detached()
    }

    /// Fetches models based on a specified inclusion criteria.
    ///
    /// - Parameter isIncluded: A closure that defines the criteria for model inclusion.
    /// - Returns: An array of models that match the criteria.
    public func getBy(_ isIncluded: @escaping (Query<Model>) -> Query<Bool>) throws -> [Model] {
        let realm = try storage.realm()
        let results = realm.objects(Model.self)
        let matched = results.where(isIncluded)
        return matched.asDetachedArray()
    }

    // MARK: - Update

    /// Inserts or updates a single model in the Realm database.
    ///
    /// If a model with the same primary key already exists, the properties are updated to that of the passed model.
    ///
    /// - Parameter model: The model to upsert.
    public func upsert(_ model: Model) throws {
        let realm = try storage.realm()
        let detached = model.detached()
        try realm.write {
            realm.add(detached, update: .modified)
        }
    }

    /// Inserts or updates an array of models in the Realm database.
    ///
    /// If a model with the same primary key as any of the passed models already exists, the properties are updated to that of the passed model.
    ///
    /// - Parameter models: The array of models to upsert.
    public func upsert(_ models: [Model]) throws {
        let realm = try storage.realm()
        let detached = models.map { $0.detached() }
        try realm.write {
            realm.add(detached, update: .modified)
        }
    }

    /// Updates a specific model using a provided modification block.
    ///
    /// - Parameters:
    ///   - model: The model to update.
    ///   - block: The modification block containing the updates.
    /// - Throws: `RepositoryError.keyNotFound` if the model lacks a primary key.
    /// - Throws: `RepositoryError.objectNotFound` if the model cannot be found.
    public func update(_ model: Model, using block: @escaping (Model) throws -> Void) throws {
        let realm = try storage.realm()
        guard let key = model.primaryKey else {
            throw RepositoryError.keyNotFound
        }
        guard let object = realm.object(ofType: Model.self, forPrimaryKey: key) else {
            throw RepositoryError.objectNotFound
        }
        try realm.write {
            try block(object)
        }
    }

    /// Updates a specific model identified by its primary key using a provided modification block.
    ///
    /// - Parameters:
    ///   - key: The primary key of the model to update.
    ///   - block: The modification block that containing the updates.
    /// - Throws: `RepositoryError.objectNotFound` if the model cannot be found.
    public func update<KeyType>(_ key: KeyType, using block: @escaping (Model) throws -> Void) throws {
        let realm = try storage.realm()
        guard let object = realm.object(ofType: Model.self, forPrimaryKey: key) else {
            throw RepositoryError.objectNotFound
        }
        try realm.write {
            try block(object)
        }
    }

    // MARK: - Delete

    /// Removes a specific model from the `Repository`.
    ///
    /// - Parameter model: The model to remove.
    /// - Throws:
    ///     - `RepositoryError.keyNotFound` if the model lacks a primary key.
    ///     - `RepositoryError.objectNotFound` if the model cannot be found.
    public func remove(_ model: Model) throws {
        let realm = try storage.realm()
        guard let key = model.primaryKey else {
            throw RepositoryError.keyNotFound
        }
        guard let model = realm.object(ofType: Model.self, forPrimaryKey: key) else {
            throw RepositoryError.objectNotFound
        }
        try realm.write {
            realm.delete(model)
        }
    }

    /// Removes a specific model identified by its primary key.
    ///
    /// - Parameter key: The primary key of the model to remove.
    /// - Throws:
    ///     - `RepositoryError.objectNotFound` if the model cannot be found.
    public func remove<KeyType>(_ key: KeyType) throws {
        let realm = try storage.realm()
        guard let model = realm.object(ofType: Model.self, forPrimaryKey: key) else {
            throw RepositoryError.objectNotFound
        }
        try realm.write {
            realm.delete(model)
        }
    }

    /// Removes an array of models from the Realm database.
    ///
    /// - Parameter models: The array of models to remove.
    public func remove(_ models: [Model]) throws {
        for model in models {
            try remove(model)
        }
    }

    /// Removes all the models of the specified type from the Realm database.
    public func removeAll() throws {
        let realm = try storage.realm()
        let all = realm.objects(Model.self)
        try realm.write {
            realm.delete(all)
        }
    }

    /// Removes all the models of the specified type and replaces them with the provided models.
    ///
    /// - Parameter models: The array of models to insert after clearing existing data.
    public func replaceAll(with models: [Model]) throws {
        let realm = try storage.realm()
        let detached = models.map { $0.detached() }
        let all = realm.objects(Model.self)
        try realm.write {
            realm.delete(all)
            realm.add(detached)
        }
    }

    // MARK: - Stream

    /// Provides a stream of all the models from the `Repository`.
    ///
    /// Every mutation of the `Repository` (all writes and updates) will result in a new array of models being emitted by the stream.
    ///
    /// - Returns: An asynchronous stream of models.
    public nonisolated var stream: AsyncThrowingStream<[Model], Error> {
        createStream {
            let realm = try self.storage.realm()
            return realm.objects(Model.self)
        }
    }

    /// Provides a stream of the specific model identified by its primary key.
    ///
    /// Every mutation of the given model (all writes and updates) will result in a new model being emitted by the stream.
    ///
    /// - Parameter key: The primary key of the model.
    /// - Returns: An asynchronous stream of the model.
    /// - Throws: `RepositoryError.objectNotFound` if the model was deleted.
    public nonisolated func getStream<KeyType>(for key: KeyType) -> AsyncThrowingStream<Model, Error> {
        createStream {
            let realm = try self.storage.realm()
            guard let object = realm.object(ofType: Model.self, forPrimaryKey: key) else {
                throw RepositoryError.keyNotFound
            }
            return object
        }
    }
}
