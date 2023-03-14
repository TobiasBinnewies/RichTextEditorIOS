//
//  EditorLine.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 08.03.23.
//

import Foundation
import UIKit

class EditorLine: Equatable {
    public static func == (lhs: EditorLine, rhs: EditorLine) -> Bool {
        return lhs.text == rhs.text && lhs.range == rhs.range
    }

    /// Text contained in the current line.
    public let text: NSAttributedString

    /// Range of text in the `EditorView` for the current line.
    public let range: NSRange

    /// Determines if the current line starts with given text.
    /// Text comparison is case-sensitive.
    /// - Parameter text: Text to compare
    /// - Returns:
    /// `true` if the current line text starts with the given string.
    public func startsWith(_ text: String) -> Bool {
        return self.text.string.hasPrefix(text)
    }

    /// Determines if the current line ends with given text.
    /// Text comparison is case-sensitive.
    /// - Parameter text: Text to compare
    /// - Returns:
    /// `true` if the current line text ends with the given string.
    public func endsWith(_ text: String) -> Bool {
        self.text.string.hasSuffix(text)
    }

    // EditorLine may only be initialized internally
    init(text: NSAttributedString, range: NSRange) {
        self.text = text
        self.range = range
    }
    
    private var listItemStorage: ListItem? = nil
    private var paraStyleStorage: NSParagraphStyle? = nil
    private var isListLineStorage: Bool! = nil
    
    var listItem: ListItem? {
        if isListLineStorage == nil {
            getListItem()
        }
        return listItemStorage
    }
    
    var paraStyle: NSParagraphStyle? {
        if isListLineStorage == nil {
            getListItem()
        }
        return paraStyleStorage
    }
    
    var isListLine: Bool {
        if isListLineStorage == nil {
            getListItem()
        }
        return isListLineStorage
    }
    
    private func getListItem() {
        if let attrs = self.text.getActiveAttributes(), let listItem = attrs[.listItem] as? ListItem, let paraStyle = attrs[.paragraphStyle] as? NSParagraphStyle {
            self.isListLineStorage = true
            self.listItemStorage = listItem
            self.paraStyleStorage = paraStyle
            return
        }
        isListLineStorage = false
    }
}

class ModifiedLine: EditorLine {
    let oldLine: EditorLine
    
    override var listItem: ListItem? {
        if let listItem = super.listItem {
            return listItem
        }
        return oldLine.listItem
    }
    
    override var paraStyle: NSParagraphStyle? {
        if let paraStyle = super.paraStyle {
            return paraStyle
        }
        return oldLine.paraStyle
    }
    
    override var isListLine: Bool {
        if super.isListLine {
            return true
        }
        return oldLine.isListLine
    }
    
    init(text: NSAttributedString, range: NSRange, oldText: NSAttributedString, oldRange: NSRange) {
        self.oldLine = EditorLine(text: oldText, range: oldRange)
        super.init(text: text, range: range)
    }
    
    init(new: EditorLine, old: EditorLine) {
        self.oldLine = old
        super.init(text: new.text, range: new.range)
    }
}
