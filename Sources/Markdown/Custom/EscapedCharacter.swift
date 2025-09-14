//
//  EscapedCharacter.swift
//  swift-markdown
//
//  Created by kzhiquan on 2025/9/14.
//

/// An element that tags inline elements with strong emphasis.
public struct EscapedCharacter: RecurringInlineMarkup, BasicInlineContainer {
    public var _data: _MarkupData
    init(_ raw: RawMarkup) throws {
        guard case .escapedCharacter = raw.data else {
            throw RawMarkup.Error.concreteConversionError(from: raw, to: Strong.self)
        }
        let absoluteRaw = AbsoluteRawMarkup(markup: raw, metadata: MarkupMetadata(id: .newRoot(), indexInParent: 0))
        self.init(_MarkupData(absoluteRaw))
    }
    init(_ data: _MarkupData) {
        self._data = data
    }
}

// MARK: - Public API

public extension EscapedCharacter {
    // MARK: BasicInlineContainer

    init(_ newChildren: some Sequence<InlineMarkup>) {
        self.init(newChildren, inheritSourceRange: false)
    }

    init(_ newChildren: some Sequence<InlineMarkup>, inheritSourceRange: Bool) {
        let rawChildren = newChildren.map { $0.raw.markup }
        let parsedRange = inheritSourceRange ? rawChildren.parsedRange : nil
        try! self.init(.escapedCharacter(parsedRange: parsedRange, rawChildren))
    }
    
    init(_ children: [InlineMarkup], startRange: SourceRange?, endRange: SourceRange?) {
        
         // 1️⃣ 转换子节点为底层 raw markup
         let rawChildren = children.map { $0.raw.markup }
         
         // 2️⃣ 计算 parsedRange：优先使用 start/end marker 范围
         let parsedRange: SourceRange? = {
             if let start = startRange, let end = endRange {
                 return start.lowerBound..<end.upperBound
             } else if let start = startRange {
                 return start.lowerBound..<start.upperBound
             } else if let end = endRange {
                 return end.lowerBound..<end.upperBound
             } else {
                 // 如果 marker 都没有，尝试使用 children 的范围
                 return rawChildren.parsedRange
             }
         }()
         
         // 3️⃣ 调用底层 Underline 构造函数
        try! self.init(.escapedCharacter(parsedRange: parsedRange, rawChildren))
     }
    

    // MARK: PlainTextConvertibleMarkup
    var plainText: String {
        let childrenPlainText = children.compactMap {
            return ($0 as? InlineMarkup)?.plainText
        }.joined()
        return "\(childrenPlainText)"
    }

    // MARK: Visitation
    func accept<V: MarkupVisitor>(_ visitor: inout V) -> V.Result {
        return visitor.visitEscapedCharacter(self)
    }
}


/// 给 MarkupVisitor 扩展，支持 EscapedCharacter
public extension MarkupVisitor {
    
    mutating func visitEscapedCharacter(_ escapedCharacter: EscapedCharacter) -> Result {
        return defaultVisit(escapedCharacter)
    }
    
}
