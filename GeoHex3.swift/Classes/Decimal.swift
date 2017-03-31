//
//  Decimal.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import Foundation

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
    var integerValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}
