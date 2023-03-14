//
//  EditorView.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 03.03.23.
//

import Foundation
import UIKit
import SwiftUI

class EditorView: AutogrowingTextView {
    let isWriteEnabled: Bool
    let richTextEditorContext: RichTextEditorContext
//    let richTextStorageObserver: TextStorageObserver
    let richTextStorage = NSTextStorage()
    let textTracker = TextTracker()
    var inInit: Bool = true
    
    
    var selectedAttributes: [NSAttributedString.Key : Any] {
        if selectedRange.isEmpty {
            return typingAttributes
        }
        return attributedText.getActiveAttributes(inRange: selectedRange)!
    }
    
    var selectedText: NSAttributedString {
        attributedText.attributedSubstring(from: selectedRange)
    }
    
    var currentContentLine: EditorLine {
        attributedText.currentContentLine(from: selectedRange.location)!
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let tab = "\t"
        let enter = "\r"
        let b = "b"
        let i = "i"
        let u = "u"
        let o = "o"

        return [
            UIKeyCommand(input: tab, modifierFlags: [], action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: tab, modifierFlags: .shift, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: enter, modifierFlags: .shift, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: enter, modifierFlags: .control, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: enter, modifierFlags: .alternate, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: b, modifierFlags: .command, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: i, modifierFlags: .command, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: u, modifierFlags: .command, action: #selector(handleKeyCommand(command:))),
            UIKeyCommand(input: o, modifierFlags: .command, action: #selector(handleKeyCommand(command:))),
        ]
    }
    
    @objc
    func handleKeyCommand(command: UIKeyCommand) {
        guard isWriteEnabled,
              let input = command.input,
              let key = KeyboardKeys(string: input, modifierFlags: command.modifierFlags)
        else { return }
        
        richTextEditorContext.handleKeyboardInput(key: key, currentLine: currentContentLine)
    }
    
    init(context: RichTextEditorContext, writeEnabled: Bool) {
        self.isWriteEnabled = writeEnabled
        self.richTextEditorContext = context
//        self.richTextStorageObserver = TextStorageObserver(textTracker: textTracker)
        let textContainer = NSTextContainer()
        let layoutManager = LayoutManager()
        layoutManager.addTextContainer(textContainer)
//        richTextStorageObserver.storage.addLayoutManager(layoutManager)
        richTextStorage.addLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: textContainer)
//        self.isScrollEnabled = true
        if !isWriteEnabled {
            self.isSelectable = false
            self.isEditable = false
        }
        attributedText = context.text
        self.delegate = context
        self.textTracker.editor = self
        layoutManager.editorView = self
        context.editor = self
        if self.textStorage.length == 0 {
            self.typingAttributes = context.defaultAttributes
        }
        self.textColor = context.defaultAttributes[.foregroundColor] as? UIColor ?? UIColor(Color.primary)
        self.backgroundColor = .clear
        textContainer.heightTracksTextView = true
        textContainer.widthTracksTextView = true
        self.inInit = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleListLineChanges() {
        // Remove LineFiller if line is not empty
        if currentContentLine.text.string.contains(Character.blankLineFiller), (currentContentLine.range.length > 1 || !currentContentLine.isListLine) {
            let blankCharLocations = currentContentLine.text.string[Character.blankLineFiller]
            blankCharLocations.reversed().forEach { location in
                removeCharacters(in: NSRange(location: currentContentLine.range.location + location, length: 1))
            }
        }
        
        textTracker.changedLines.forEach { changedLine in
            guard let listItem = changedLine.listItem, let paraStyle = changedLine.paraStyle else { return }

            // Insert LineFiller if line is empty
            if changedLine.range.length == 0, !richTextEditorContext.listIntentionalDelete {
                var attributes = typingAttributes
                attributes[.listItem] = listItem
                attributes[.paragraphStyle] = paraStyle
                insert(NSAttributedString.getAttributedLineFiller(attr: attributes), at: changedLine.range.location)
                return
            }
        }
        handleToolbar()
    }
    
    func handleTextChange() {
        guard isWriteEnabled else { return }
        handleTypingAttributes()
        handleToolbar()
        richTextEditorContext.onChange(attributedText)
    }
    
    func handleUIChange() {
        guard isWriteEnabled else { return }
        handleTypingAttributes()
        handleToolbar()
    }
    
    func handleTypingAttributes() {
        guard isWriteEnabled else { return }
        if currentContentLine.isListLine {
            addTypingAttribute(.listItem, value: currentContentLine.listItem!)
            addTypingAttribute(.paragraphStyle, value: currentContentLine.paraStyle!)
        } else {
            removeTypingAttribute(.listItem)
            removeTypingAttribute(.paragraphStyle)
        }
    }
    
    func addTypingAttribute(_ name: NSAttributedString.Key, value: Any) {
        if selectedRange.length == 0 {
            typingAttributes[name] = value
        }
    }
    
    func removeTypingAttribute(_ name: NSAttributedString.Key) {
        if selectedRange.length == 0 {
            typingAttributes.removeValue(forKey: name)
        }
    }
    
    private func handleToolbar() {
        guard isWriteEnabled, isFirstResponder else { return }
        var toolbarSelection = ToolbarSelection()
        let selectedAttributes = selectedAttributes
        
        if let font = selectedAttributes[.font] as? UIFont {
            toolbarSelection.textStyles[.bold] = font.contains(trait: .traitBold)
            toolbarSelection.textStyles[.italic] = font.contains(trait: .traitItalic)
            
            for style in UIFont.TextStyle.allValues {
                if style.prefferedFont == font {
                    toolbarSelection.fontStyle = style
                    break
                }
            }
        }
        
        if let listItem = selectedAttributes[.listItem] as? ListItem {
            toolbarSelection.selectedList = listItem
        }
        
        if let style = selectedAttributes[.underlineStyle] as? Int {
            toolbarSelection.textStyles[.underline] = (style == NSUnderlineStyle.single.rawValue)
        }
        
        if let style = selectedAttributes[.strikethroughStyle] as? Int {
            toolbarSelection.textStyles[.strikethrough] = (style == NSUnderlineStyle.single.rawValue)
        }
        
        richTextEditorContext.updateToolbarAttributes(toolbarSelection)
    }
}
