//
//  UserAction.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import Combine

protocol UserAction {
    func add(_ user: User) async throws
    func delete(userId: UUID) async throws
    func rename(userId: UUID, name: String) async throws
}
