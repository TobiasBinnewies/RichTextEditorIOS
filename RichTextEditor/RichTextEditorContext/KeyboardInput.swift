//
//  KeyboardInput.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 08.03.23.
//

import Foundation
import UIKit

enum KeyboardKeys: CaseIterable {
    case enter, shiftEnter, tab, shiftTab, backspace, commandB, commandI, commandU, commandO, commandZ, commandY
    
    init?(string: String, modifierFlags: UIKeyModifierFlags) {
        for key in KeyboardKeys.allCases {
            if key.getString() == string && key.getModifiers() == modifierFlags {
                self = key
                return
            }
        }
        return nil
    }
    
    func getString() -> String {
        switch self {
        case .enter:
            return "\n"
        case .shiftEnter:
            return "\r"
        case .tab:
            return "\t"
        case .shiftTab:
            return "\t"
        case .backspace:
            return ""
        case .commandB:
            return "b"
        case .commandI:
            return "i"
        case .commandU:
            return "u"
        case .commandO:
            return "o"
        case .commandY:
            return "y"
        case .commandZ:
            return "z"
        }
    }
    
    func getModifiers() -> UIKeyModifierFlags {
        switch self {
        case .enter:
            return []
        case .shiftEnter:
            return .shift
        case .tab:
            return []
        case .shiftTab:
            return .shift
        case .backspace:
            return []
        case .commandB:
            return .command
        case .commandI:
            return .command
        case .commandU:
            return .command
        case .commandO:
            return .command
        case .commandY:
            return .command
        case .commandZ:
            return .command
        }
    }
}

extension RichTextEditorContext {
    func handleKeyboardInput(key: KeyboardKeys, currentLine: EditorLine) {
        guard currentLine.isListLine, editor.inFocus else { return }
        switch key {
        case .enter:
            toggleListAttribute(listItem: nil, inRange: currentLine.range)
            return
        case .tab:
            styleListIndent(mode: .indent)
        case .backspace:
            toggleListAttribute(listItem: nil, inRange: currentLine.range)
        case .shiftEnter:
            return
        case .shiftTab:
            styleListIndent(mode: .indent)
        case .commandB:
            styleText(style: .bold)
        case .commandI:
            styleText(style: .italic)
        case .commandU:
            styleText(style: .underline)
        case .commandO:
            styleText(style: .strikethrough)
        case .commandZ:
            editor.textTracker.undo()
        case .commandY:
            editor.textTracker.redo()
        }
    }
}
