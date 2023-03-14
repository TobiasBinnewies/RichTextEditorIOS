//
//  String.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation

extension String {
    /// Returns the char at the given position
    subscript(offset: Int) -> Character? {
        if offset < 0 || offset > self.count-1 {
            return nil
        }
        return self[index(startIndex, offsetBy: offset)]
    }
    
    /// Returns all postions the given char is present
    subscript (char: Character) -> [Int] {
        var idxArr: [Int] = []
        var idx = 0
        for c in self {
            if c == char {
                idxArr.append(idx)
            }
            idx += 1
        }
        return idxArr
    }
    
    static func ==(lhs: String, rhs: Character) -> Bool {
        return lhs == String(rhs)
    }
}

extension Character {
    /// Zero width space - used for laying out the list bullet/number in an empty line.
    /// This is required when using tab on a blank bullet line. Without this, layout calculations are not performed.
    static let blankLineFiller: Character = "X"
        //"\u{200B}"
}
