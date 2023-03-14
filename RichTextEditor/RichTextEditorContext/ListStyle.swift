//
//  ListStyle.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 07.03.23.
//

import Foundation
import UIKit

public enum IndentMode {
    case indent, outdent
}

extension RichTextEditorContext {
    public func styleList(sequence: [SequenceGenerator], inRange: NSRange? = nil) {
        guard editor.inFocus else { return }
        let allLinesInRange = editor.attributedText.contentLines(inRange: inRange ?? editor.selectedRange)
        guard !allLinesInRange.isEmpty else { return }
        var fullRange = NSRange(location: allLinesInRange.first!.range.location, endLocation: allLinesInRange.last!.range.endLocation)
        if fullRange.length == 0 {
            editor.insert(NSAttributedString(string: String(Character.blankLineFiller), attributes: defaultAttributes), at: fullRange.location)
            fullRange.length = 1
        }
        toggleListAttribute(listItem: ListItem(indentLvl: 1, symbols: sequence), inRange: fullRange)
    }
    
    public func styleListIndent(mode: IndentMode, inRange: NSRange? = nil) {
        guard editor.inFocus else { return }
        let allLinesInRange = editor.attributedText.contentLines(inRange: inRange ?? editor.selectedRange)
        guard !allLinesInRange.isEmpty else { return }
        for line in allLinesInRange {
            guard let paraStyle = line.paraStyle else { continue }
            let lvl = {
                switch mode {
                case .indent:
                    return Int(paraStyle.headIndent) / lvlHeadIndent + 1
                case .outdent:
                    return Int(paraStyle.headIndent) / lvlHeadIndent - 1
                }
            }()
            setIndentation(levelToSet: lvl, inRange: line.range)
        }
    }
    
    func toggleListAttribute(listItem: ListItem?, inRange range: NSRange) {
        let selectedText = editor.attributedText.attributedSubstring(from: range)
        
        var listAction: EditType = .delete
        var currentListItem: ListItem! = nil
        
        if let listItem = listItem {
            let allActiveAttributes = selectedText.getActiveAttributes()!
            if let activeAttributeValue = allActiveAttributes[.listItem] as? ListItem {
                currentListItem = activeAttributeValue
                if activeAttributeValue != listItem {
                    listAction = .change
                }
            } else {
                listAction = .add
            }
        }
        
        switch listAction {
        case .change:
            currentListItem.symbols = listItem!.symbols
            editor.append(NSAttributedString())
            editor.handleListLineChanges()
        case .add:
            setListItem(item: listItem!, in: range)
        case .delete:
            removeListItem(in: range)
        }
        editor.attributedText.enumerateAttribute(.paragraphStyle, in: range, options: .longestEffectiveRangeNotRequired) { attrValue, range, _ in
            switch listAction {
            case .change:
                return
            case .add:
                setParagraphStyle(in: range, indentLevel: 1)
            case .delete:
                removeParagraphStyle(in: range)
            }
        }
        editor.handleListLineChanges()
    }
    
    private func setIndentation(levelToSet lvl: Int, inRange range: NSRange) {
        if lvl < 1 {
            removeListItem(in: range)
        }
        editor.attributedText.enumerateAttribute(.paragraphStyle, in: range, options: .longestEffectiveRangeNotRequired) { attrValue, range, _ in
            if lvl > 0 {
                setParagraphStyle(in: range, indentLevel: lvl)
            } else {
                removeParagraphStyle(in: range)
            }
        }
        editor.handleListLineChanges()
    }
    
    private func setListItem(item: ListItem, in range: NSRange) {
        editor.richTextStorage.addAttribute(.listItem, value: item, range: range)
        editor.addTypingAttribute(.listItem, value: item)
    }
    
    private func removeListItem(in range: NSRange) {
        editor.richTextStorage.removeAttribute(.listItem, range: range)
        editor.removeTypingAttribute(.listItem)
        listIntentionalDelete = true
    }
    
    private func setParagraphStyle(in range: NSRange, indentLevel lvl: Int) {
        editor.richTextStorage.addAttribute(.paragraphStyle, value: getParaStyleForLvl(lvl), range: range)
        editor.addTypingAttribute(.paragraphStyle, value: getParaStyleForLvl(lvl))
    }
    
    private func removeParagraphStyle(in range: NSRange) {
        editor.richTextStorage.removeAttribute(.paragraphStyle, range: range)
        editor.removeTypingAttribute(.paragraphStyle)
    }
    
    private func getParaStyleForLvl(_ lvl: Int) -> NSParagraphStyle {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.headIndent = CGFloat(lvlHeadIndent * lvl)
        paraStyle.firstLineHeadIndent = CGFloat(lvlHeadIndent * lvl)
        return paraStyle
    }
}
