//
//  Repository+CollectionStream.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift

extension Repository {
    nonisolated func createStream(
        from models: @escaping @RealmActor () throws -> Results<Model>
    ) -> AsyncThrowingStream<[Model], Error> where Model: Detachable {
        .init { continuation in
            Task.detached { @RealmActor in
                do {
                    let observer = CollectionObserver<Model> { _, results in
                        let results = results.asDetachedArray()
                        continuation.yield(results)
                    }
                    continuation.onTermination = { @Sendable _ in
                        observer.stopObserving()
                    }
                    let models = try models()
                    await observer.startObserving(models)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
