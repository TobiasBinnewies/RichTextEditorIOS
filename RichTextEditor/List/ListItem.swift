//
//  NSAttributedString.Key.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation

extension NSAttributedString.Key {
    static let listItem = NSAttributedString.Key("_listItem")
    static let skipNextListMarker = NSAttributedString.Key("_skipNextListMarker")
}

public class ListItem: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(indentLvl, forKey: Key.indentLvl.rawValue)
        coder.encode(nextItem, forKey: Key.nextItem.rawValue)
        coder.encode(symbols, forKey: Key.symbols.rawValue)
    }
    
    enum Key: String {
        case symbols = "symbols"
        case indentLvl = "indentLvl"
        case nextItem = "nextItem"
    }
    
    required convenience public init?(coder: NSCoder) {
        let indentLvl = coder.decodeInteger(forKey: Key.indentLvl.rawValue)
        let nextItem = coder.decodeObject(of: ListItem.self, forKey: Key.nextItem.rawValue)
        let symbols = coder.decodeObject(of: [NSArray.self, SequenceGenerator.self, NSString.self], forKey: Key.symbols.rawValue) as! [SequenceGenerator]
        
        self.init(indentLvl: indentLvl, symbols: symbols, nextItem: nextItem)

    }
    
    var indentLvl: Int
    public var symbols: [SequenceGenerator]
    var nextItem: ListItem?
    
    init(indentLvl: Int, symbols: [SequenceGenerator], nextItem: ListItem? = nil) {
        self.indentLvl = indentLvl
        self.symbols = symbols
        self.nextItem = nextItem
    }
    
    var symbol: SequenceGenerator {
        symbols[((indentLvl-1) % symbols.count)]
    }
    
    func getSymbol(forLevel: Int) -> SequenceGenerator {
        symbols[((forLevel-1) % symbols.count)]
    }
    
    func changeIndent(indentMode: Indentation) {
        switch indentMode {
        case .indent:
            indentLvl += 1
        case .outdent:
            indentLvl -= 1
        }
    }
    
//    func deepCopy() -> ListItem {
//        ListItem(indentLvl: self.indentLvl, symbols: self.symbols, nextItem: self.nextItem)
//    }
    
    static func ==(_ lhs: ListItem, _ rhs: ListItem) -> Bool {
        return lhs.indentLvl == rhs.indentLvl &&
            lhs.symbols.elementsEqual(rhs.symbols, by: { $0 == $1 })  &&
            lhs.nextItem == rhs.nextItem
    }
    
    static func !=(_ lhs: ListItem, _ rhs: ListItem) -> Bool {
        return !(lhs == rhs)
    }
}
