//
//  XY.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

public struct XY {
    public var x: Double
    public var y: Double
}

extension XY: Equatable {}

public func ==(lhs: XY, rhs: XY) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
