//
//  ToolbarSelection.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import SwiftUI
import UIKit

public struct ToolbarSelection {
    public var textStyles: [StyleAttribute : Bool] = [
        .bold: false,
        .italic: false,
        .strikethrough: false,
        .underline: false
    ]
    public var selectedList: ListItem? = nil
    public var fontStyle: UIFont.TextStyle? = nil
    public var isUndoAvailable: Bool = false
    public var isRedoAvailable: Bool = false
    public var inFocus: Bool = false
    
    public init() {
        
    }
}

public enum StyleAttribute: CaseIterable {
    case bold
    case italic
    case underline
    case strikethrough
    
//    static let allValues = [StyleAttributes.bold, StyleAttributes.italic, StyleAttributes.underline, StyleAttributes.strikethrough]
    
    public func getSystemImageName() -> String {
        switch self {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .strikethrough:
            return "strikethrough"
        }
    }
    
    public func getKeyboardShortcut() -> KeyboardShortcut {
        switch self {
        case .bold:
            return KeyboardShortcut("b")
        case .italic:
            return KeyboardShortcut("i")
        case .underline:
            return KeyboardShortcut("u")
        case .strikethrough:
            return KeyboardShortcut("o")
        }
    }
}
