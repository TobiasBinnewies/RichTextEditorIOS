//
//  Array.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 07.03.23.
//

import Foundation

extension Array {
    static func ==(_ lhs: [SequenceGenerator], _ rhs: [SequenceGenerator]) -> Bool {
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
    
    func map<T>(_ body: ((Element, Int)->T)) -> [T] {
        var result: [T] = []
        for i in 0..<self.count {
            result.append(body(self[i], i))
        }
        return result
    }
    
    func forEach(_ body: ((Element, Int) -> Void)) {
        for i in 0..<self.count {
            body(self[i], i)
        }
    }
}
