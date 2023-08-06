//
//  Repository+Publisher.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Combine
import RealmSwift

extension Repository {

    // MARK: - Create

    /// Inserts a single model into the Realm database using Combine.
    ///
    /// - Parameter model: The model to insert.
    /// - Returns: A publisher that emits once the insertion is complete.
    public nonisolated func insertCombine(_ model: Model) -> AnyPublisher<Void, Error> {
        withPublisher { try self.insert(model) }
    }

    /// Inserts an array of models into the Realm database using Combine.
    ///
    /// - Parameter models: The array of models to insert.
    /// - Returns: A publisher that emits once the insertion is complete.
    public nonisolated func insertCombine(_ models: [Model]) -> AnyPublisher<Void, Error> {
        withPublisher { try self.insert(models) }
    }

    // MARK: - Update

    /// Upserts (inserts or updates) a single model in the Realm database using Combine.
    ///
    /// - Parameter model: The model to upsert.
    /// - Returns: A publisher that emits once the upsert operation is complete.
    public nonisolated func upsertCombine(_ model: Model) -> AnyPublisher<Void, Error> {
        withPublisher { try self.upsert(model) }
    }

    /// Upserts (inserts or updates) an array of models in the Realm database using Combine.
    ///
    /// - Parameter models: The array of models to upsert.
    /// - Returns: A publisher that emits once the upsert operation is complete.
    public nonisolated func upsertCombine(_ models: [Model]) -> AnyPublisher<Void, Error> {
        withPublisher { try self.upsert(models) }
    }

    /// Updates a specific model using Combine.
    ///
    /// - Parameters:
    ///   - model: The model to update.
    ///   - block: The block containing the update logic.
    /// - Returns: A publisher that emits once the update is complete.
    public nonisolated func updateCombine(
        _ model: Model,
        using block: @escaping (Model) throws -> Void
    ) -> AnyPublisher<Void, Error> {
        withPublisher { try self.update(model, using: block) }
    }

    /// Updates a specific model identified by its primary key using Combine.
    ///
    /// - Parameters:
    ///   - key: The primary key of the model to update.
    ///   - block: The block containing the update logic.
    /// - Returns: A publisher that emits once the update is complete.
    public nonisolated func updateCombine<KeyType>(
        _ key: KeyType,
        using block: @escaping (Model) throws -> Void
    ) -> AnyPublisher<Void, Error> {
        withPublisher { try self.update(key, using: block) }
    }

    // MARK: - Delete

    /// Removes a specific model from the Realm database using Combine.
    ///
    /// - Parameter model: The model to remove.
    /// - Returns: A publisher that emits once the removal is complete.
    public nonisolated func removeCombine(_ model: Model) -> AnyPublisher<Void, Error> {
        withPublisher { try self.remove(model) }
    }

    /// Removes a specific model identified by its primary key from the Realm database using Combine.
    ///
    /// - Parameter key: The primary key of the model to remove.
    /// - Returns: A publisher that emits once the removal is complete.
    public nonisolated func removeCombine<KeyType>(_ key: KeyType) -> AnyPublisher<Void, Error> {
        withPublisher { try self.remove(key) }
    }

    /// Removes an array of models from the Realm database using Combine.
    ///
    /// - Parameter models: The array of models to remove.
    /// - Returns: A publisher that emits once the removal is complete.
    public nonisolated func removeCombine(_ models: [Model]) -> AnyPublisher<Void, Error> {
        withPublisher { try self.remove(models) }
    }

    /// Removes all models of the specified type from the Realm database using Combine.
    ///
    /// - Returns: A publisher that emits once all models have been removed.
    public nonisolated func removeAllCombine() -> AnyPublisher<Void, Error> {
        withPublisher { try self.removeAll() }
    }

    /// Replaces all models of the specified type in the Realm database with the given models using Combine.
    ///
    /// - Parameter models: The array of models to insert as a replacement.
    /// - Returns: A publisher that emits once the replacement is complete.
    public nonisolated func replaceAllCombine(with models: [Model]) -> AnyPublisher<Void, Error> {
        withPublisher { try self.replaceAll(with: models) }
    }

    // MARK: - Publishers

    /// Provides a publisher for all models stored in the `Repository`.
    ///
    /// Every mutation of the `Repository` (all writes and updates) will result in a new array of models being emitted by the publisher.
    ///
    /// - Returns: A publisher that emits an array of models.
    public nonisolated var publisher: AnyPublisher<[Model], Error> {
        CollectionPublisher<Model> {
            let realm = try self.storage.realm()
            return realm.objects(Model.self)
        }
        .shareReplay()
        .eraseToAnyPublisher()
    }

    /// Provides a publisher of the specific model identified by its primary key.
    ///
    /// Every mutation of the given model (all writes and updates) will result in a new model being emitted by the publisher.
    ///
    /// - Parameter key: The primary key of the model to fetch.
    /// - Returns: A publisher that emits the fetched model.
    public nonisolated func getCombine<KeyType>(for key: KeyType) -> AnyPublisher<Model, Error> {
        ObjectPublisher<Model> {
            let realm = try self.storage.realm()
            return realm.object(ofType: Model.self, forPrimaryKey: key)
        }
        .shareReplay()
        .eraseToAnyPublisher()
    }
}
