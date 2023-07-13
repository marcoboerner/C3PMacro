import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import C3PMacroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]

final class C3PMacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
    }

    func testMacroWithStringLiteral() {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
    }
}
