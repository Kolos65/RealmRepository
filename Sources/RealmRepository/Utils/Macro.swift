//
//  Detachable+Macro.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 09. 24..
//

@attached(extension, conformances: Detachable, names: arbitrary)
public macro DataModel() = #externalMacro(module: "RealmRepositoryMacrosPlugin", type: "DataModelMacro")
