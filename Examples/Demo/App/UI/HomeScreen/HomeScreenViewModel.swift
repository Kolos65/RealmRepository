//
//  HomeScreenViewModel.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI
import Resolver
import Combine

final class HomeScreenViewModel: ObservableObject {

    // MARK: Injected Properties

    @Injected private var action: UserAction
    @Injected private var store: UserStore

    // MARK: Data

    var users: AnyAsyncSequence<[User]> {
        store.getAll()
    }

    // MARK: Actions

    func addUser() {
        Task { try await action.add(User.random) }
    }

    func deleteUser(with id: UUID) {
        Task { try await action.delete(userId: id) }
    }

    func renameUser(with id: UUID, to name: String) {
        Task { try await action.rename(userId: id, name: name) }
    }
}
