//
//  Int.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation

extension Int {
    var lowerLetter: String {
        if self < 1 {
            return "NIL"
        }
        if self == 1 {
            return "a"
        }
        if self > 702 {
            return ">zz"
        }
        let uniCodeA = UnicodeScalar("a")
//        let letterCnt: Int = (self-1) / 26

        var result: Int = self-1
        var remainders: [Int] = []
        while result != 0 {
            if remainders.count > 0 && result / 27 == 0 {
                remainders.append(result % 27)
                break
            }
            remainders.append(result % 26)
            result = result / 26
        }
        if remainders.count == 1 {
            return String(UnicodeScalar(uniCodeA.value + UInt32(remainders[0]))!)
        }
        var lowerLetter: String = String(UnicodeScalar(uniCodeA.value + UInt32(remainders.popLast()!) - UInt32(1))!)
        for remainder in remainders.reversed() {
            lowerLetter.append(String(UnicodeScalar(uniCodeA.value + UInt32(remainder))!))
        }
        return lowerLetter
    }
    
    var upperLetter: String {
        if self < 1 {
            return "NIL"
        }
        if self == 1 {
            return "A"
        }
        if self > 702 {
            return ">ZZ"
        }
        let uniCodeA = UnicodeScalar("A")

        var result: Int = self-1
        var remainders: [Int] = []
        while result != 0 {
            if remainders.count > 0 && result / 27 == 0 {
                remainders.append(result % 27)
                break
            }
            remainders.append(result % 26)
            result = result / 26
        }
        if remainders.count == 1 {
            return String(UnicodeScalar(uniCodeA.value + UInt32(remainders[0]))!)
        }
        var upperLetter: String = String(UnicodeScalar(uniCodeA.value + UInt32(remainders.popLast()!) - UInt32(1))!)
        for remainder in remainders.reversed() {
            upperLetter.append(String(UnicodeScalar(uniCodeA.value + UInt32(remainder))!))
        }
        return upperLetter
    }
    
    var upperRomanNumeral: String {
        if self < 1 {
            return "NIL"
        }
        if self > 3999 {
            return ">MMMCMXCIX"
        }
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"), (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        for i in mappingList {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
    
    var lowerRomanNumeral: String {
        if self < 1 {
            return "NIL"
        }
        if self > 3999 {
            return ">mmmcmxcix"
        }
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "m"), (900, "cm"), (500, "d"), (400, "cd"), (100, "c"), (90, "xc"), (50, "l"), (40, "xl"), (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i")]
        for i in mappingList {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
}
