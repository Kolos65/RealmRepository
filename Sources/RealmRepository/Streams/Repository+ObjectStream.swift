//
//  ObjectStream.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift

extension Repository {
    nonisolated func createStream(
        from model: @escaping @RealmActor () throws -> Model
    ) -> AsyncThrowingStream<Model, Error> where Model: Detachable {
        .init { continuation in
            Task.detached { @RealmActor in
                do {
                    let observer = ObjectObserver<Model> { _, result in
                        guard let result else {
                            continuation.finish(throwing: RepositoryError.objectNotFound)
                            return
                        }
                        continuation.yield(result.detached())
                    }
                    continuation.onTermination = { @Sendable _ in
                        observer.stopObserving()
                    }
                    let model = try model()
                    continuation.yield(model.detached())
                    await observer.startObserving(model)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
