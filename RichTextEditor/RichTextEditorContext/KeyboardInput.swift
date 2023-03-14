//
//  KeyboardInput.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 08.03.23.
//

import Foundation
import UIKit

enum KeyboardKeys {
    case enter, shiftEnter, tab, shiftTab, backspace, commandB, commandI, commandU, commandO
    
    init?(string: String, modifierFlags: UIKeyModifierFlags) {
        switch string {
        case "\t":
            if modifierFlags.isEmpty {
                self = .tab
                return
            }
            self = .shiftTab
        case "\n", "\r":
            if modifierFlags.isEmpty {
                self = .enter
                return
            }
            self = .shiftEnter
        case "b":
            if modifierFlags.contains(.command) {
                self = .commandB
                return
            }
            return nil
        case "i":
            if modifierFlags.contains(.command) {
                self = .commandI
                return
            }
            return nil
        case "u":
            if modifierFlags.contains(.command) {
                self = .commandU
                return
            }
            return nil
        case "o":
            if modifierFlags.contains(.command) {
                self = .commandO
                return
            }
            return nil
        default:
            return nil
        }
    }
}

extension RichTextEditorContext {
    func handleKeyboardInput(key: KeyboardKeys, currentLine: EditorLine) {
        guard currentLine.isListLine else { return }
        switch key {
        case .enter:
            toggleListAttribute(listItem: nil, inRange: currentLine.range)
            return
        case .tab:
            return
        case .backspace:
            toggleListAttribute(listItem: nil, inRange: currentLine.range)
        case .shiftEnter:
            return
        case .shiftTab:
            return
        case .commandB:
            styleText(style: .bold)
        case .commandI:
            styleText(style: .italic)
        case .commandU:
            styleText(style: .underline)
        case .commandO:
            styleText(style: .strikethrough)
        }
    }
}
