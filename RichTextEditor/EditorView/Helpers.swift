//
//  TextStorage.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 08.03.23.
//

import Foundation
import UIKit

extension EditorView {
    func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
        textStorage.addAttributes(attrs, range: range)
    }

    func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        textStorage.addAttribute(name, value: value, range: range)
    }
    
    func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        textStorage.removeAttribute(name, range: range)
    }
    
    func removeCharacters(in range: NSRange) {
        let currentLocation = selectedRange.location
        textStorage.replaceCharacters(in: range, with: "")
        if currentLocation != selectedRange.location { return }
        updateSelection(changedRange: NSRange(location: range.location, length: 0), oldRange: range)
    }

    func replaceCharacters(in range: NSRange, with str: String) {
        textStorage.replaceCharacters(in: range, with: str)
        updateSelection(changedRange: NSRange(location: range.location, length: str.count), oldRange: range)
    }

    func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        textStorage.replaceCharacters(in: range, with: attrString)
        updateSelection(changedRange: NSRange(location: range.location, length: attrString.length), oldRange: range)
    }

    func append(_ attrString: NSAttributedString) {
        textStorage.append(attrString)
    }
    
    func insert(_ attrString: NSAttributedString, at location: Int) {
        textStorage.insert(attrString, at: location)
        updateSelection(changedRange: NSRange(location: location, length: attrString.length), oldRange: NSRange(location: location, length: 0))
    }
    
    func updateSelection(changedRange: NSRange, oldRange: NSRange) {
        guard selectedRange.length == 0 else { fatalError("selectedRange.length has to be 0 at this point") }
        let currentLocation = selectedRange.location
        
        if currentLocation <= oldRange.location { return }
        
        let newLocation = currentLocation + (changedRange.length - oldRange.length)
        selectedRange = NSRange(location: newLocation, length: 0)
    }
}

//class TextStorageObserver {
//    let textTracker: TextTracker
//    let storage = NSTextStorage()
//
//    func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
//        storage.addAttributes(attrs, range: range)
//        updateTextTracker()
//    }
//
//    func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
//        storage.addAttribute(name, value: value, range: range)
//        updateTextTracker()
//    }
//
//    func replaceCharacters(in range: NSRange, with str: String) {
//        storage.replaceCharacters(in: range, with: str)
//        updateTextTracker()
//    }
//
//    func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
//        storage.replaceCharacters(in: range, with: attrString)
//        updateTextTracker()
//    }
//
//    func append(_ attrString: NSAttributedString) {
//        storage.append(attrString)
//        updateTextTracker()
//    }
//
//    func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
//        storage.removeAttribute(name, range: range)
//        updateTextTracker()
//    }
//
//    init(textTracker: TextTracker) {
//        self.textTracker = textTracker
//    }
//
//    private func updateTextTracker() {
//        self.textTracker.textChanged(toText: storage, isUserChange: false)
//    }
//}
