//
//  UserStoreImpl.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import Resolver
import RealmRepository

public class UserService {

    // MARK: Injected properties

    @Injected private var repository: Repository<UserDataModel>
}

// MARK: - UserStore

extension UserService: UserStore {
    func getAll() -> AnyAsyncSequence<[User]> {
        repository.stream
            .map { $0.map(\.asDomainModel) }
            .eraseToAnyAsyncSequence()
    }
}

// MARK: - UserAction

extension UserService: UserAction {
    func delete(userId: UUID) async throws {
        try await repository.remove(userId)
    }

    func add(_ user: User) async throws {
        try await repository.insert(user.asDataModel)
    }

    func rename(userId: UUID, name: String) async throws {
        try await repository.update(userId) { user in
            user.name = name
        }
    }
}
