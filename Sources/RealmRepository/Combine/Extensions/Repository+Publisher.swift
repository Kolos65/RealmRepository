//
//  Repository+Publisher.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Combine

extension Repository {
    nonisolated func withPublisher(
        for operation: @RealmActor @Sendable @escaping () throws -> Void
    ) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { promise in
                Task.detached { @RealmActor in
                    do {
                        try operation()
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .shareReplay()
        .eraseToAnyPublisher()
    }
}
