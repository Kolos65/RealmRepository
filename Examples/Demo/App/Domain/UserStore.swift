//
//  UserStore.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

protocol UserStore {
    func getAll() -> AnyAsyncSequence<[User]>
}
