import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct SlopeSubsetMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // checks if the declaration is of type enum declaration, meaning the macro needs to be attached to a type that is an enum
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            fatalError()
        }

        let identifier = enumDecl.identifier
        let identifierLowercased = identifier.text.dropLast(identifier.text.count - 1).lowercased() + identifier.text.dropFirst()
        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        let initializer = try InitializerDeclSyntax("init?(_ \(raw: identifierLowercased): \(identifier))") {
            try SwitchExprSyntax("switch \(raw: identifierLowercased)") {
                for element in elements {
                    SwitchCaseSyntax(
                        """
                        case .\(element.identifier):
                            self = .\(element.identifier)
                        """
                        )
                }
                SwitchCaseSyntax("default: return nil")
            }
        }

        return [DeclSyntax(initializer)]
    }
}

@main
struct C3PMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        SlopeSubsetMacro.self
    ]
}
