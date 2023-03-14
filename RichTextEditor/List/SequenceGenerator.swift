//
//  SequenceGenerator.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit

public class SequenceGenerator: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public enum SequenceType: String {
        case numeric = "numeric", upperLetter = "upperLetter", lowerLetter = "lowerLetter", upperRomanLetter = "upperRomanLetter", lowerRomanLetter = "lowerRomanLetter", diamond = "diamond", square = "square", dot = "dot"
    }
    
    let withBraces: Bool
    let count: Int
    let sequence: SequenceType
    
    enum Key: String {
        case withBraces = "withBraces"
        case count = "count"
        case sequence = "sequence"
    }
    
    required public init?(coder: NSCoder) {
        let withBraces = coder.decodeBool(forKey: Key.withBraces.rawValue)
        let count = coder.decodeInteger(forKey: Key.count.rawValue)
        let rawSequence = coder.decodeObject(forKey: Key.sequence.rawValue) as! String
        self.withBraces = withBraces
        self.count = count
        self.sequence = SequenceType(rawValue: rawSequence)!
    }
    
    public init(sequence: SequenceType, withBraces: Bool = false, count: Int = 1) {
        self.withBraces = withBraces
        self.count = count
        self.sequence = sequence
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(withBraces, forKey: Key.withBraces.rawValue)
        coder.encode(count, forKey: Key.count.rawValue)
        coder.encode(sequence.rawValue, forKey: Key.sequence.rawValue)
    }
    
    /// Returns a value representing the given index.
    /// - Parameter index: Index for which the value is being fetched.
    public func value(at index: Int) -> ListLineMarker {
        switch sequence {
        case .numeric:
            return valueNumeric(at: index)
        case .upperLetter:
            return valueUpperLetter(at: index)
        case .lowerLetter:
            return valueLowerLetter(at: index)
        case .upperRomanLetter:
            return valueUpperRomanLetter(at: index)
        case .lowerRomanLetter:
            return valueLowerRomanLetter(at: index)
        case .diamond:
            return valueDiamond(at: index)
        case .square:
            return valueSquare(at: index)
        case .dot:
            return valueDot(at: index)
        }
    }
    
    private func valueNumeric(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1))\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueUpperLetter(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        var marker = ""
        for _ in 0..<count {
            marker.append("\((index + 1).upperLetter)")
        }
        let text = "\(withBraces ? "(" : "")\(marker)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueLowerLetter(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        var marker = ""
        for _ in 0..<count {
            marker.append("\((index + 1).lowerLetter)")
        }
        let text = "\(withBraces ? "(" : "")\(marker)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueUpperRomanLetter(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1).upperRomanNumeral)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueLowerRomanLetter(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1).lowerRomanNumeral)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueDiamond(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "◈"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueSquare(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "▣"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    private func valueDot(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "◉"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
    
    public static func ==(_ lhs: SequenceGenerator, _ rhs: SequenceGenerator) -> Bool {
        return lhs.withBraces == rhs.withBraces &&
            lhs.count == rhs.count &&
            lhs.sequence == rhs.sequence
    }
}
