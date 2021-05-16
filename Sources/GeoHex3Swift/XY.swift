//
//  XY.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

public class XY {
    fileprivate var _x: Double
    fileprivate var _y: Double
    
    public init(x: Double, y: Double) {
        self._x = x
        self._y = y
    }
    
    public var x: Double {
        return self._x
    }
    
    public var y: Double {
        return self._y
    }
}

extension XY: Equatable {}

public func ==(lhs: XY, rhs: XY) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
