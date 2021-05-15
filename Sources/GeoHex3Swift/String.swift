//
//  String.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import Foundation

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = self.index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(from: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(startIndex, offsetBy: length)
        return String(self[startIndex ..< endIndex])
    }
    
    func index(character: Character) -> Int {
        let index = self.enumerated().filter { (idx, c) in c == character }.first?.0
        guard let offset = index else {
            return -1
        }
        return offset
    }
    
    func match(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches.count > 0
    }
    
    var length: Int {
        return self.count
    }
    
    subscript (index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    subscript (index: Int) -> String {
        return String(self[index])
    }
}
