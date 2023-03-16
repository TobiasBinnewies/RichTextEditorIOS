//
//  RichTextEditorContext.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit
import SwiftUI

public class RichTextEditorContext: NSObject, UITextViewDelegate {
    weak var editor: EditorView!
    let updateToolbarAttributes: ((ToolbarSelection)->Void)
    let defaultParaStyle: NSParagraphStyle = {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.firstLineHeadIndent = 0
        paraStyle.headIndent = 0
        return paraStyle
    }()
    let lvlHeadIndent = 25
    let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.preferredFont(forTextStyle: .body),
        .foregroundColor: UIColor(Color.primary),
    ]
    var listIntentionalDelete: Bool = false
    
    public var inFocus: Bool {
        get {
            guard editor != nil else { return false }
            return editor.inFocus
        }
        set {
            editor.inFocus = newValue
        }
    }
    
    public init(updateToolbarAttributes: @escaping ((ToolbarSelection)->Void)) {
        self.updateToolbarAttributes = updateToolbarAttributes
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? EditorView else { return false }
        // Enter und Tab Registrieren (Bei Liste Tab entfernen)
        let currentLine = text.count == 0 ? textView.attributedText.currentContentLine(from: range.endLocation)! : textView.attributedText.currentContentLine(from: range.location)!
        if text == "\n", currentLine.text.string == Character.blankLineFiller {
            handleKeyboardInput(key: .enter, currentLine: currentLine)
            return false
        }
        if text.count == 0, currentLine.text.string == Character.blankLineFiller || (currentLine.isListLine && currentLine.range.location == range.endLocation) {
            handleKeyboardInput(key: .backspace, currentLine: currentLine)
            return false
        }
        
        textView.textTracker.registerPossibleChange(text: textView.attributedText, newText: text, changeRange: range)
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        listIntentionalDelete = false
        editor.textTracker.registerChange(text: textView.attributedText)
        editor.handleListLineChanges()
        if (textView.attributedText.length == 0) {
            editor.handleTextChange()
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
//        editor.textTracker.selectionChanged(toSelection: textView.selectedRange)
        editor.handleUIChange()
    }
    
    public func setText(_ text: NSAttributedString) {
        guard editor != nil else { return }
        editor.attributedText = text
    }
    
    public func undo() {
        editor.textTracker.undo()
    }
    
    public func redo() {
        editor.textTracker.redo()
    }
}
