//
//  Zone.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import Foundation
import CoreLocation

public class Zone {
    fileprivate let _coordinate: CLLocationCoordinate2D
    fileprivate let _xy: XY
    fileprivate let _code: String
    fileprivate let _level: Int
    fileprivate var _polygonCache: [CLLocationCoordinate2D]?
    
    public init(coordinate: CLLocationCoordinate2D, xy: XY, code: String) {
        self._coordinate = coordinate
        self._xy = xy
        self._code = code
        self._level = code.length - 2
    }
    
    public var x: Double {
        return self._xy.x
    }
    
    public var y: Double {
        return self._xy.y
    }
    
    public var position: XY {
        return self._xy
    }
    
    public var latitude: Double {
        return self._coordinate.latitude
    }
    
    public var longitude: Double {
        return self._coordinate.longitude
    }
    
    public var code: String {
        return self._code
    }
    
    public var level: Int {
        return self._level
    }
    
    public var hexSize: Double {
        return GeoHex3.hexSize(level: self.level)
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return self._coordinate
    }
    
    public var polygon: [CLLocationCoordinate2D] {
        if self._polygonCache == nil {
            let h_lat = self.latitude
            let h_xy = GeoHex3.loc2xy(latitude: self.latitude, longitude: self.longitude)
            let h_x = h_xy.x
            let h_y = h_xy.y
            let h_deg = tan(Double.pi * (60.0 / 180.0))
            let h_size = self.hexSize
            let h_top = GeoHex3.xy2loc(x: h_x, y: h_y + h_deg * h_size).latitude
            let h_btm = GeoHex3.xy2loc(x: h_x, y: h_y - h_deg * h_size).latitude
            
            let h_l = GeoHex3.xy2loc(x: h_x - 2 * h_size, y: h_y).longitude
            let h_r = GeoHex3.xy2loc(x: h_x + 2 * h_size, y: h_y).longitude
            let h_cl = GeoHex3.xy2loc(x: h_x - 1 * h_size, y: h_y).longitude
            let h_cr = GeoHex3.xy2loc(x: h_x + 1 * h_size, y: h_y).longitude
            
            self._polygonCache = [
                CLLocationCoordinate2D(latitude: h_lat, longitude: h_l),
                CLLocationCoordinate2D(latitude: h_top, longitude: h_cl),
                CLLocationCoordinate2D(latitude: h_top, longitude: h_cr),
                CLLocationCoordinate2D(latitude: h_lat, longitude: h_r),
                CLLocationCoordinate2D(latitude: h_btm, longitude: h_cr),
                CLLocationCoordinate2D(latitude: h_btm, longitude: h_cl)
            ]
        }
        return self._polygonCache ?? []
    }
}


extension Zone: Equatable {}

public func ==(lhs: Zone, rhs: Zone) -> Bool {
    return lhs.code == rhs.code && lhs.position == rhs.position
}

