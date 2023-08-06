//
//  UI+DI.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Resolver

extension Resolver {
    static func registerUI() {
        register { HomeScreenViewModel() }
    }
}
