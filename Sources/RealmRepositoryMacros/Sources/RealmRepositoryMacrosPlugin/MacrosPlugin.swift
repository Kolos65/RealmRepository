//
//  MacrosPlugin.swift
//  RealmRepositoryMacros
//
//  Created by Kolos Foltanyi on 2023. 08. 09..
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct RealmRepositoryMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DataModelMacro.self
    ]
}
