//
//  TextStyle.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit

extension RichTextEditorContext {
    public func styleText(style: StyleAttribute) {
        guard editor.inFocus else { return }
        switch style {
        case .bold:
            toggleFontTraint(trait: .traitBold, inRange: editor.selectedRange)
        case .italic:
            toggleFontTraint(trait: .traitItalic, inRange: editor.selectedRange)
        case .underline:
            toggleAttribute(attribute: (key: .underlineStyle, value: 1), inRange: editor.selectedRange)
        case .strikethrough:
            toggleAttribute(attribute: (key: .strikethroughStyle, value: 1), inRange: editor.selectedRange)
        }
    }
    
    public func styleFont(style: UIFont.TextStyle) {
        guard editor.inFocus else { return }
        toggleAttribute(attribute: (key: .font, value: UIFont.preferredFont(forTextStyle: style)), inRange: editor.selectedRange)
    }
    
    private func toggleFontTraint(trait: UIFontDescriptor.SymbolicTraits, inRange range: NSRange) {
        let selectedText = editor.attributedText.attributedSubstring(from: range)
        if editor.attributedText.length == 0 || editor.selectedRange == .zero || selectedText.length == 0 {
            guard let font = editor.typingAttributes[.font] as? UIFont else { return }
            editor.typingAttributes[.font] = font.toggled(trait: trait)
            editor.handleUIChange()
            return
        }
        
        let isTraintFullActiveInSelectedText: Bool = selectedText.getActiveTraits()!.contains(trait)

        editor.attributedText.enumerateAttribute(.font, in: editor.selectedRange, options: .longestEffectiveRangeNotRequired) { font, range, _ in
            if let font = font as? UIFont {
                let fontToApply = isTraintFullActiveInSelectedText ? font.removing(trait: trait) : font.adding(trait: trait)
                editor.richTextStorage.addAttribute(.font, value: fontToApply, range: range)
            }
        }
    }
    
    private func toggleAttribute(attribute: (key: NSAttributedString.Key, value: Any), inRange range: NSRange) {
        let selectedText = editor.attributedText.attributedSubstring(from: range)
        if editor.attributedText.length == 0 || range == .zero || selectedText.length == 0 {
            if attribute.key == .font {
                editor.typingAttributes[.font] = attribute.value
                editor.handleUIChange()
                return
            }
            if editor.typingAttributes[attribute.key] == nil {
                editor.typingAttributes[attribute.key] = attribute.value
            } else {
                var typingAttributes = editor.typingAttributes
                typingAttributes[attribute.key] = nil
                editor.typingAttributes = typingAttributes
            }
            editor.handleUIChange()
            return
        }
        
        let areAttributesFullActiveInSelectedText: Bool = {
            let allActiveAttributes = selectedText.getActiveAttributes()!
            if let activeAttributeValue = allActiveAttributes[attribute.key], anyEquals(activeAttributeValue, attribute.value) {
                return true
            }
            return false
        }()
        
        editor.attributedText.enumerateAttribute(attribute.key, in: editor.selectedRange, options: .longestEffectiveRangeNotRequired) { attrValue, range, _ in
            if !areAttributesFullActiveInSelectedText {
                editor.richTextStorage.addAttribute(attribute.key, value: attribute.value, range: range)
            } else {
                if attribute.key == .font { return }
                editor.richTextStorage.removeAttribute(attribute.key, range: range)
            }
        }
    }
}
