//
//  AppAssembly.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Resolver
import RealmRepository

extension Resolver {
    static func registerAppDependencies() {
        registerDataServices()
        registerUI()
    }
}
