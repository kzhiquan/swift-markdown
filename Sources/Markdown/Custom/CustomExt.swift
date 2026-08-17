//
//  Custom+Ext.swift
//  swift-markdown
//
//  Created by kzhiquan on 2025/9/12.
//


//MARK: - 初始化 增加一个 Range 参数
extension Text {
    
    public init(_ literalText: String, range: SourceRange?) {
        try! self.init(.text(parsedRange: range, string: literalText))
    }
    
    public init(_ literalText: String, startRange: SourceRange?, endRange: SourceRange?) {
         
         // 计算 parsedRange：优先使用 start/end marker 范围
         let parsedRange: SourceRange? = {
             if let start = startRange, let end = endRange {
                 return start.lowerBound..<end.upperBound
             } else if let start = startRange {
                 return start.lowerBound..<start.upperBound
             } else if let end = endRange {
                 return end.lowerBound..<end.upperBound
             } else {
                 return nil
             }
         }()
         
        try! self.init(.text(parsedRange: parsedRange, string: literalText))
        
     }
    
}

extension InlineHTML {

    public init(_ literalText: String, range: SourceRange?) {
        try! self.init(.inlineHTML(parsedRange: range, html: literalText))
    }

}

extension SoftBreak {
    
    public init(range: SourceRange?) {
        try! self.init(.softBreak(parsedRange: range))
    }
    
}


extension InlineCode {
    
    public init(_ code: String, range: SourceRange?) {
        try! self.init(.inlineCode(parsedRange: range, code: code))
    }
    
}


extension Strong {
    
    public init(_ newChildren: some Sequence<InlineMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.strong(parsedRange: range, rawChildren))
    }
    
}

extension Emphasis {
    
    public init(_ newChildren: some Sequence<InlineMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.emphasis(parsedRange: range, rawChildren))
    }
    
}

extension Strikethrough {
    
    public init(_ newChildren: some Sequence<InlineMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.strikethrough(parsedRange: range, rawChildren))
    }
    
}

extension Link {
    
    public init<Children: Sequence>(destination: String? = nil, title: String? = nil, _ children: Children, range: SourceRange?) where Children.Element == RecurringInlineMarkup {

        let destinationToUse: String?
        if let d = destination, d.isEmpty {
            destinationToUse = nil
        } else {
            destinationToUse = destination
        }
        let titleToUse: String?
        if let t = title, t.isEmpty {
            titleToUse = nil
        } else {
            titleToUse = title
        }

        try! self.init(.link(destination: destinationToUse, title: titleToUse, parsedRange: range, children.map { $0.raw.markup }))
    }
    
}

extension Image {

    /// 重建 Image 时保留解析器给出的源码范围。
    /// Menote 在提升 inline 子树时只迁移位置，不应丢失图片地址、标题、alt 子节点或 range。
    public init<Children: Sequence>(source: String? = nil, title: String? = nil, _ children: Children, range: SourceRange?) where Children.Element == RecurringInlineMarkup {
        let sourceToUse: String?
        if let source, source.isEmpty {
            sourceToUse = nil
        } else {
            sourceToUse = source
        }
        let titleToUse: String?
        if let title, title.isEmpty {
            titleToUse = nil
        } else {
            titleToUse = title
        }

        try! self.init(
            .image(
                source: sourceToUse,
                title: titleToUse,
                parsedRange: range,
                children.map { $0.raw.markup }
            )
        )
    }

}

extension CodeBlock {

    /// 重建 CodeBlock 时同时保留语义 payload 与已验证的源码范围。
    public init(language: String? = nil, code: String, range: SourceRange?) {
        try! self.init(.codeBlock(parsedRange: range, code: code, language: language))
    }

}

extension Paragraph {
    
    public init(_ newChildren: some Sequence<InlineMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.paragraph(parsedRange: range, rawChildren))
    }
    
}

extension Heading {
    
    public init<Children: Sequence>(level: Int, _ children: Children, range: SourceRange?) where Children.Element == InlineMarkup {
        try! self.init(.heading(level: level, parsedRange: range, children.map { $0.raw.markup }))
    }
    
}



extension ListItem {
    
    public init<Children: Sequence>(checkbox: Checkbox? = .none, _ children: Children, range: SourceRange?) where Children.Element == BlockMarkup {
        try! self.init(.listItem(checkbox: checkbox, parsedRange: range, children.map { $0.raw.markup }))
    }
    
}

extension OrderedList {
    
    public init<Items: Sequence>(_ items: Items, range: SourceRange?) where Items.Element == ListItem {
        try! self.init(.orderedList(parsedRange: range, items.map { $0.raw.markup }))
    }

    /// 职责：在更新有序列表起始号时保留当前节点的 parsed range，避免 range 被清空。
    /// 背景：默认 `startIndex` setter 会把 parsedRange 置为 nil，影响依赖 range 的下游逻辑。
    /// 处理逻辑：
    /// 1) 读取当前 raw children 与 parsedRange；
    /// 2) 仅替换 ordered list 的 startIndex；
    /// 3) 通过 replacingSelf 回写节点，保持 children 与 range 不变。
    public mutating func setStartIndexPreservingRange(_ newValue: UInt) {
        guard case let .orderedList(current) = self._data.raw.markup.data else { return }
        guard current != newValue else { return }
        let preservedRange = self.range
        self._data = self._data.replacingSelf(
            .orderedList(
                parsedRange: preservedRange,
                self._data.raw.markup.copyChildren(),
                startIndex: newValue
            )
        )
    }
    
}

extension UnorderedList {
    
    public init<Items: Sequence>(_ items: Items, range: SourceRange?) where Items.Element == ListItem {
        try! self.init(.unorderedList(parsedRange: range, items.map { $0.raw.markup }))
    }
    
}

extension BlockQuote {
    
    public init(_ newChildren: some Sequence<BlockMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.blockQuote(parsedRange: range, rawChildren))
    }
    
}

extension ThematicBreak {
    public init(range: SourceRange?) {
        try! self.init(.thematicBreak(parsedRange: range))
    }
}


extension Document {
    
    public init(_ children: some Sequence<BlockMarkup>, range: SourceRange?) {
        let rawChildren = children.map { $0.raw.markup }
        try! self.init(.document(parsedRange: range, rawChildren))
    }
    
}
    
    
