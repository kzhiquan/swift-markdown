/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
@testable import Markdown

class CodeBlockTests: XCTestCase {
    var testCodeBlock: CodeBlock {
        let language = "swift"
        let code = "func foo() {}"
        let codeBlock = CodeBlock(language: language, code)
        XCTAssertEqual(.some(language), codeBlock.language)
        XCTAssertEqual(code, codeBlock.code)
        return codeBlock
    }

    func testCodeBlockLanguage() {
        let codeBlock = testCodeBlock
        var newCodeBlock = codeBlock
        newCodeBlock.language = "c"

        XCTAssertEqual(.some("c"), newCodeBlock.language)
        XCTAssertFalse(codeBlock.isIdentical(to: newCodeBlock))

        var codeBlockWithoutLanguage = newCodeBlock
        codeBlockWithoutLanguage.language = nil
        XCTAssertNil(codeBlockWithoutLanguage.language)
        XCTAssertFalse(codeBlock.isIdentical(to: codeBlockWithoutLanguage))
    }

    func testCodeBlockCode() {
        let codeBlock = testCodeBlock
        let newCode = "func bar() {}"
        var newCodeBlock = codeBlock
        newCodeBlock.code = newCode

        XCTAssertEqual(newCode, newCodeBlock.code)
        XCTAssertEqual(codeBlock.language, newCodeBlock.language)
        XCTAssertFalse(codeBlock.isIdentical(to: newCodeBlock))
    }

    /// Rebuilding a code block during source normalization must preserve its payload and parsed range.
    func testCodeBlockWithRange() {
        let range: SourceRange = SourceLocation(line: 2, column: 3, source: nil)
            ..< SourceLocation(line: 4, column: 1, source: nil)
        let codeBlock = CodeBlock(
            language: "swift",
            code: "let value = 1\n\n",
            range: range
        )

        XCTAssertEqual(codeBlock.language, "swift")
        XCTAssertEqual(codeBlock.code, "let value = 1\n\n")
        XCTAssertEqual(codeBlock.range, range)
        XCTAssertEqual(codeBlock.childCount, 0)
    }
}
