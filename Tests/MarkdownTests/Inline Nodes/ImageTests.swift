/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
@testable import Markdown

class ImageTests: XCTestCase {
    func testImageSource() {
        let source = "test.png"
        let image = Image(source: source, title: "")
        XCTAssertEqual(source, image.source)
        XCTAssertEqual(0, image.childCount)

        let newSource = "new.png"
        var newImage = image
        newImage.source = newSource
        XCTAssertEqual(newSource, newImage.source)
        XCTAssertFalse(image.isIdentical(to: newImage))
    }

    func testImageTitle() {
        let title = "title"
        let image = Image(source: "_", title: title)
        XCTAssertEqual(title, image.title)
        XCTAssertEqual(0, image.childCount)

        do {
            let source = "![Alt](test.png \"\(title)\")"
            let document = Document(parsing: source)
            let image = document.child(through:[
                (0, Paragraph.self),
                (0, Image.self),
            ]) as! Image
            XCTAssertEqual(title, image.title)
        }
    }
    
    func testLinkFromSequence() {
        let children = [Text("Hello, world!")]
        let image = Image(source: "test.png", title: "title", children)
        let expectedDump = """
            Image source: "test.png" title: "title"
            └─ Text "Hello, world!"
            """
        XCTAssertEqual(expectedDump, image.debugDescription())
    }

    /// Rebuilding an image during source normalization must preserve its metadata, children, and parsed range.
    func testImageFromSequenceWithRange() throws {
        let range: SourceRange = SourceLocation(line: 2, column: 1, source: nil)..<SourceLocation(line: 2, column: 35, source: nil)
        let childRange: SourceRange = SourceLocation(line: 2, column: 3, source: nil)..<SourceLocation(line: 2, column: 6, source: nil)
        let image = Image(
            source: "image.png",
            title: "title",
            [Text("alt", range: childRange)],
            range: range
        )

        XCTAssertEqual(image.source, "image.png")
        XCTAssertEqual(image.title, "title")
        XCTAssertEqual(image.range, range)
        let altText = try XCTUnwrap(image.child(at: 0) as? Text)
        XCTAssertEqual(altText.string, "alt")
        XCTAssertEqual(altText.range, childRange)
    }
}
