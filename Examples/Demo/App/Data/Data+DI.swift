//
//  User+DI.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Resolver
import RealmRepository

extension Resolver {
    static func registerDataServices() {
        register { Repository<UserDataModel>() }
            .scope(.unique)

        register { UserService() }
            .implements(UserAction.self)
            .implements(UserStore.self)
    }
}
