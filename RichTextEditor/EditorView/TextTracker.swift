//
//  TextTracker.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 07.03.23.
//

import Foundation
import UIKit

class TextTracker {
    weak var editor: EditorView!
    
    var lastText: NSAttributedString = NSAttributedString()
    var newText: String = ""
    var newAttributedText: NSAttributedString = NSAttributedString()
    var currentText: NSAttributedString {
        editor.attributedText
    }
    var changeRange: NSRange = NSRange()
    var newTextRange: NSRange {
        NSRange(location: changeRange.location, length: newText.count)
    }
    
    private var textHistory: [NSAttributedString] = []
    private var textHistoryPointer: Int = -1
    private var textHistoryLastEditType: EditType = .change
    var undoAvailable: Bool {
        textHistoryPointer > 0
    }
    var redoAvailable: Bool {
        textHistoryPointer < textHistory.count-1
    }
    
    var changeType: EditType {
        if changeRange.length == 0 {
            return .add
        }
        if newText.count == 0 {
            return .delete
        }
        return .change
    }
    
    var changedLines: [ModifiedLine] {
//        if !changeHappen { fatalError("Not allowed to access this property while current registered change is not up-to-date") }
        
        if changeType == .add {
            let newLines = currentText.contentLines(inRange: newTextRange)
            let oldLine = lastText.currentContentLine(from: newTextRange.location)!
            
            return newLines.map { newLine in
                ModifiedLine(new: newLine, old: oldLine)
            }
        }
        
        if changeType == .delete {
            let oldLines = lastText.contentLines(inRange: changeRange)
            let newLine = currentText.currentContentLine(from: changeRange.location)!
            
            return oldLines.map { oldLine in
                ModifiedLine(new: newLine, old: oldLine)
            }
        }
        
        let newLines = currentText.contentLines(inRange: newTextRange)
        let oldLines = lastText.contentLines(inRange: changeRange)
        let allOldLinesRange = NSRange(location: oldLines.first!.range.location, endLocation: oldLines.last!.range.endLocation)
        let allOldLines = EditorLine(text: lastText.attributedSubstring(from: allOldLinesRange), range: allOldLinesRange)
        return newLines.map { newLine in
            ModifiedLine(new: newLine, old: allOldLines)
        }
    }
    
    var changeHappen: Bool = true
 
    func registerPossibleChange(text: NSAttributedString, newText: String, changeRange: NSRange) {
        self.lastText = text
        self.changeRange = changeRange
        self.newText = newText
        self.newAttributedText = NSAttributedString()
        self.changeHappen = false
    }
    
    func registerChange(text: NSAttributedString) {
        self.changeHappen = true
//        self.currentText = text
        self.newAttributedText = text.attributedSubstring(from: changeRange.fitInRange(text.fullRange))
        appendTextHistory(changeType: self.changeType, changedText: self.newText)
    }
    
    func registerStyleChange() {
        appendTextHistory(changeType: .style, changedText: nil)
    }
    
    func undo() {
        guard undoAvailable else { return }
        let newPointer = self.textHistoryPointer - 1
        editor.attributedText = self.textHistory[newPointer]
        self.textHistoryPointer = newPointer
        editor.handleTextChange()
    }
    
    func redo() {
        guard redoAvailable else { return }
        let newPointer = self.textHistoryPointer + 1
        editor.attributedText = self.textHistory[newPointer]
        self.textHistoryPointer = newPointer
        editor.handleTextChange()
    }
    
    func appendTextHistory(changeType: EditType, changedText: String?) {
        self.textHistory.removeLast(self.textHistory.count-self.textHistoryPointer-1)
        
        let lastChangeType = self.textHistoryLastEditType
        self.textHistoryLastEditType = changeType == .add && (changedText == " " || changedText == "\n") ? .initinal : changeType
        if (changeType == .add || changeType == .delete), changeType == lastChangeType  {
            self.textHistory[self.textHistory.count-1] = self.currentText
            self.textHistoryPointer = self.textHistory.count-1
            return
        }
        self.textHistory.append(self.currentText)
        self.textHistoryPointer = self.textHistory.count-1
        return
    }
    
//    private func getNextTextHistoryStep(isUndo: Bool) -> Int {
//        var pointer = self.textHistoryPointer
//        var changeType: EditType? = isUndo ? self.textHistory[pointer].changeType : nil
//
//        while true {
//            pointer += isUndo ? -1 : 1
//            if pointer < 0 {
//                return 0
//
//            }
//            if pointer >= self.textHistory.count {
//                return self.textHistory.count-1
//
//            }
//            guard let changeType = changeType else {
//                changeType = self.textHistory[pointer].changeType
//                continue
//            }
//            if changeType == .initinal {
//                changeType = self.textHistory[pointer].changeType
//                continue
//            }
//            if self.textHistory[pointer].changeType != changeType {
//                return pointer
//            }
//        }
//    }
    
//    private func getTextChanges() {
//        if lastSelection.length == 0 {
//            if currentText.length > lastText.length {
//                changeType = .add
//                oldText = nil
//                newText = getAddedText()
//                return
//            }
//            changeType = .delete
//            oldText = getDeletedText()
//            newText = nil
//            return
//        }
//        let result = getChangedTexts()
//        changeType = .change
//        oldText = result.old
//        newText = result.new
//    }
//
//    private func getDeletedText() -> EditorLine {
//        let oldRange = NSRange(location: currentSelection.location, length: lastText.length-currentText.length)
//        return EditorLine(text: lastText.attributedSubstring(from: oldRange), range: oldRange)
//    }
//
//    private func getAddedText() -> EditorLine {
//        // TODO: Wrong range (probably) --> DEBUG
//        let range = NSRange(location: currentSelection.location-(currentText.length-lastText.length), endLocation: currentSelection.location)
//        return EditorLine(text: currentText.attributedSubstring(from: NSRange(location: currentSelection.location-(currentText.length-lastText.length), endLocation: currentSelection.location)), range: range)
//    }
//
//    private func getChangedTexts() -> (old: EditorLine, new: EditorLine) {
//        let newRange = NSRange(location: lastSelection.location, endLocation: currentSelection.location)
//        let oldRange = lastSelection
//        return (old: EditorLine(text: lastText.attributedSubstring(from: oldRange), range: oldRange), new: EditorLine(text: currentText.attributedSubstring(from: newRange), range: newRange))
//    }
}
