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

extension BlockQuote {
    
    public init(_ newChildren: some Sequence<BlockMarkup>, range: SourceRange?) {
        let rawChildren = newChildren.map { $0.raw.markup }
        try! self.init(.blockQuote(parsedRange: range, rawChildren))
    }
    
}


extension Document {
    
    public init(_ children: some Sequence<BlockMarkup>, range: SourceRange?) {
        let rawChildren = children.map { $0.raw.markup }
        try! self.init(.document(parsedRange: range, rawChildren))
    }
    
}
    
    

