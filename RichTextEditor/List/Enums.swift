//
//  Enums.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit


public enum ListLineMarker {
    case string(NSAttributedString)
    case image(UIImage)
}

enum Indentation {
    case indent
    case outdent
}
enum EditType {
    case delete, add, change, style, initinal
}
