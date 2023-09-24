//
//  DetachableMacro.swift
//  RealmRepositoryMacros
//
//  Created by Kolos Foltanyi on 2023. 08. 09..
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum DataModelMacroMacroError: Error, CustomStringConvertible {
    case onlyApplicableToClasses
    case onlyApplicableToFinalClasses
    case onlyApplicableToRealmObjectSubclasses

    public var description: String {
        switch self {
        case .onlyApplicableToClasses:
            return "@DataModel can only be applied to final classes"
        case .onlyApplicableToFinalClasses:
            return "@DataModel classes must be final"
        case .onlyApplicableToRealmObjectSubclasses:
            return "@DataModel can only be applied to Realm Object subclasses"
        }
    }
}

public struct DataModelMacro: ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      attachedTo declaration: some DeclGroupSyntax,
      providingExtensionsOf type: some TypeSyntaxProtocol,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let declaration = declaration.as(ClassDeclSyntax.self) else {
            throw DataModelMacroMacroError.onlyApplicableToClasses
        }

        guard declaration.modifiers.contains(where: { $0.name.tokenKind == .keyword(.final) }) else {
            throw DataModelMacroMacroError.onlyApplicableToFinalClasses
        }

        guard let inheritanceClause = declaration.inheritanceClause,
              inheritanceClause.inheritedTypes.contains(where: {
                  ["Object", "EmbeddedObject"].contains($0.type.trimmedDescription)
              }) else {
            throw DataModelMacroMacroError.onlyApplicableToRealmObjectSubclasses
        }

        let members = declaration.memberBlock.members
        let variableDecl = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                !$0.bindings.contains(where: { $0.accessorBlock != nil })
                && $0.bindingSpecifier.tokenKind == .keyword(.var)
            }
        let variableNames = variableDecl.compactMap { $0.bindings.first?.pattern }
        var detachment = ""
        for (index, name) in variableNames.enumerated() {
            detachment.append("self.\(name.trimmed) = detach(model.\(name.trimmed))")
            if index != variableNames.indices.last {
                detachment.append("\n")
            }
        }

        let isPublic = declaration.modifiers.contains { $0.name.tokenKind == .keyword(.public) }
        let access = isPublic ? "public " : ""

        let conformance = SyntaxNodeString(stringLiteral: """
        extension \(type.trimmed): Detachable {
            \(access)convenience init(detaching model: \(declaration.name.text)) {
                self.init()
                \(detachment)
            }
        }
        """)
        return [try ExtensionDeclSyntax(conformance)]
    }
}
