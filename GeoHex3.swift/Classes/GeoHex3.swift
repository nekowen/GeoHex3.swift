//
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import Foundation
import CoreLocation

public class GeoHex3 {
    public static let VERSION = "3.2"
    
    /// Hexを取得する
    /// Get the hexdata
    ///
    /// - Parameters:
    ///   - latitude: latitude ex): 35.12345
    ///   - longitude: longitude ex): 140.12345
    ///   - level: hexlevel ex): 7
    /// - Returns: hex
    public class func getZone(latitude: Double, longitude: Double, level: Int) -> Zone {
        let xy = self.getXY(latitude: latitude, longitude: longitude, level: level)
        return self.getZone(x: xy.x, y: xy.y, level: level)
    }
    
    /// HexcodeからHexを取得する
    /// Get the hex from hexcode
    ///
    /// - Parameter code: Hexcode ex): XM1234567
    /// - Returns: hex
    public class func getZone(code: String) -> Zone {
        let xy = self.getXY(code: code)
        let level = code.length - 2
        return self.getZone(x: xy.x, y: xy.y, level: level)
    }
    
    /// XYクラスからHexを取得する
    /// Get the hex from XYclass
    ///
    /// - Parameters:
    ///   - xy: Position
    ///   - level: hexlevel ex): 7
    /// - Returns: hex
    public class func getZone(xy: XY, level: Int) -> Zone {
        return self.getZone(x: xy.x, y: xy.y, level: level)
    }
    
    /// XY位置からHexを取得する
    /// Get the hex from position
    ///
    /// - Parameters:
    ///   - x: positionX ex): 12345
    ///   - y: positionY ex): 54321
    ///   - level: hexlevel level ex): 7
    /// - Returns: hex
    public class func getZone(x: Int, y: Int, level: Int) -> Zone {
        return self.getZone(x: Double(x), y: Double(y), level: level)
    }
    
    /// 緯度軽度からHexを取得する
    /// Get the hex from coordinate
    ///
    /// - Parameters:
    ///   - coordinate: location
    ///   - level: hexlevel level ex): 7
    /// - Returns: hex
    public class func getZone(coordinate: CLLocationCoordinate2D, level: Int) -> Zone {
        return self.getZone(latitude: coordinate.latitude, longitude: coordinate.longitude, level: level)
    }
    
    /// エリアからHex配列を取得する
    /// Get the hexArray from area
    ///
    /// - Parameters:
    ///   - southWest: southWest coord
    ///   - northEast: northEast coord
    ///   - level: hexlevel
    ///   - buffer: bufferArea
    /// - Returns: zone
    public class func getZone(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D, level: Int, buffer: Bool) -> [Zone] {
        guard let xys = self.getXY(min_lat: southWest.latitude, min_lon: southWest.longitude, max_lat: northEast.latitude, max_lon: northEast.longitude, level: level, buffer: buffer) else {
            return []
        }
        return xys.map { self.getZone(xy: $0, level: level) }
    }
}

extension GeoHex3 {
    fileprivate static let H_BASE = 20037508.34
    fileprivate static let H_DEG = Double.pi * (30.0/180.0)
    fileprivate static let H_K = tan(H_DEG)
    fileprivate static let H_KEY = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    class func getZone(x: Double, y: Double, level: Int) -> Zone {
        let h_size = self.hexSize(level: level)
        var h_x = x
        var h_y = y
        let unit_x = 6 * h_size
        let unit_y = 6 * h_size * self.H_K
        let h_lat = (self.H_K * h_x * unit_x + h_y * unit_y) / 2.0
        let h_lon = (h_lat - h_y * unit_y) / self.H_K
        
        let z_loc = self.xy2loc(x: h_lon, y: h_lat)
        var z_loc_x = z_loc.longitude
        let z_loc_y = z_loc.latitude
        
        let max_hsteps = pow(3.0, level + 2).doubleValue
        let hsteps = abs(h_x - h_y)
        
        if hsteps == max_hsteps {
            if h_x > h_y {
                swap(&h_x, &h_y)
            }
            z_loc_x = -180.0
        }
        
        let h_code = self.encode(x: h_x, y: h_y, z_loc_x: z_loc_x, z_loc_y: z_loc_y, level: level)
        return Zone(coordinate: CLLocationCoordinate2D(latitude: z_loc_y, longitude: z_loc_x),
                    xy: XY(x: x, y: y),
                    code: h_code)
    }
    
    /// 緯度軽度からXYクラスを取得する
    /// Get the XYclass from coordinate
    ///
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 軽度
    ///   - level: hexlevel
    /// - Returns: XYclass
    public class func getXY(latitude: Double, longitude: Double, level: Int) -> XY {
        let h_size = self.hexSize(level: level)
        let z_xy = self.loc2xy(latitude: latitude, longitude: longitude)
        let latitude_grid = z_xy.y
        let longitude_grid = z_xy.x
        let unit_x = 6 * h_size
        let unit_y = 6 * h_size * self.H_K
        let h_pos_x = (longitude_grid + latitude_grid / self.H_K) / unit_x
        let h_pos_y = (latitude_grid - self.H_K * longitude_grid) / unit_y
        let h_x_0 = floor(h_pos_x)
        let h_y_0 = floor(h_pos_y)
        let h_x_q: Double = h_pos_x - h_x_0
        let h_y_q: Double = h_pos_y - h_y_0
        var h_x: Double = round(h_pos_x)
        var h_y: Double = round(h_pos_y)
        
        if h_y_q > -h_x_q + 1.0 {
            if ((h_y_q < 2.0 * h_x_q) && (h_y_q > 0.5 * h_x_q)) {
                h_x = h_x_0 + 1.0
                h_y = h_y_0 + 1.0
            }
        } else if h_y_q < -h_x_q + 1.0 {
            if (h_y_q > (2.0 * h_x_q) - 1.0) && (h_y_q < (0.5 * h_x_q) + 0.5) {
                h_x = h_x_0
                h_y = h_y_0
            }
        }
        
        return self.adjustXY(x: h_x, y: h_y, level: level)
    }
    
    /// HexcodeからXYを取得する
    /// Get the XYclass from hexcode
    ///
    /// - Parameter code: hexcode
    /// - Returns: XYclass
    public class func getXY(code: String) -> XY {
        let level: Int = code.length - 2
        var h_x: Double = 0.0
        var h_y: Double = 0.0
        
        var h_dec9 = String(self.H_KEY.index(character: code[0]) * 30 +
            self.H_KEY.index(character: code[1])) + code.substring(from: 2)
        
        if h_dec9.count > 2 &&
            String(h_dec9[0]).match(pattern: "[15]") &&
            String(h_dec9[1]).match(pattern: "[^125]") &&
            String(h_dec9[2]).match(pattern: "[^125]") {
            if h_dec9[0] == "5" {
                h_dec9 = "7" + h_dec9.substring(from: 1)
            } else if h_dec9[0] == "1" {
                h_dec9 = "3" + h_dec9.substring(from: 1)
            }
        }
        
        var d9xlen = h_dec9.length
        let repeatlen = level + 3 - d9xlen
        h_dec9 = String(repeating: "0", count: repeatlen) + h_dec9
        d9xlen += repeatlen
        
        var h_dec3 = ""
        (0 ..< d9xlen).forEach {
            (index) in
            if let dec9i = Int(h_dec9[index]) {
                let h_dec0 = String(dec9i, radix: 3)
                if h_dec0.length == 1 {
                    h_dec3 += "0"
                }
                h_dec3 += h_dec0
            } else {
                h_dec3 += "00"
            }
        }
        
        let h_dec3half = h_dec3.length / 2
        var h_decx: [String] = Array(repeating: "", count: h_dec3half)
        var h_decy: [String] = Array(repeating: "", count: h_dec3half)
        
        (0 ..< h_dec3half).forEach {
            (index) in
            h_decx[index] = h_dec3.substring(from: index * 2, length: 1)
            h_decy[index] = h_dec3.substring(from: index * 2 + 1, length: 1)
        }
        
        (0 ..< level + 3).forEach {
            (index) in
            let h_pow = pow(3.0, level + 2 - index).doubleValue
            let h_ix = Int(h_decx[index]) ?? 0
            let h_iy = Int(h_decy[index]) ?? 0
            
            if h_ix == 0 {
                h_x -= h_pow
            } else if h_ix == 2 {
                h_x += h_pow
            }
            
            if h_iy == 0 {
                h_y -= h_pow
            } else if h_iy == 2 {
                h_y += h_pow
            }
        }
        
        return self.adjustXY(x: h_x, y: h_y, level: level)
    }
    
    fileprivate class func adjustXY(x: Double, y: Double, level: Int) -> XY {
        var x = x
        var y = y
        
        let max_hsteps = pow(3, level + 2).doubleValue
        let hsteps = abs(x - y)
        
        if hsteps == max_hsteps && x > y {
            swap(&x, &y)
        } else if hsteps > max_hsteps {
            let diff = hsteps - max_hsteps
            let diff_x = floor(diff / 2.0)
            let diff_y = diff - diff_x
            var edge_x: Double = 0.0
            var edge_y: Double = 0.0
            
            if x > y {
                edge_x = x - diff_x
                edge_y = y + diff_y
                swap(&edge_x, &edge_y)
                x = edge_x + diff_x
                y = edge_y - diff_y
            } else if y > x {
                edge_x = x + diff_x
                edge_y = y - diff_y
                swap(&edge_x, &edge_y)
                x = edge_x - diff_x
                y = edge_y + diff_y
            }
        }
        
        return XY(x: x, y: y)
    }
    
    class func hexSize(level: Int) -> Double {
        return self.H_BASE / pow(3.0, Double(level) + 3)
    }
    
    class func loc2xy(latitude: Double, longitude: Double) -> XY {
        let x = longitude * H_BASE / 180.0
        var y = log(tan((90.0 + latitude) * Double.pi / 360.0)) / (Double.pi / 180.0)
        y *= H_BASE / 180.0
        return XY(x: x, y: y)
    }
    
    class func xy2loc(x: Double, y: Double) -> CLLocationCoordinate2D {
        var latitude = (y / H_BASE) * 180.0
        let longitude = (x / H_BASE) * 180.0
        latitude = 180.0 / Double.pi * (2.0 * atan(exp(latitude * Double.pi / 180.0)) - Double.pi / 2.0)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    fileprivate class func encode(x: Double, y: Double, z_loc_x: Double, z_loc_y: Double, level: Int) -> String {
        var h_code: String = ""
        var code3_x: [Int] = Array(repeating: 0, count: level+3)
        var code3_y: [Int] = Array(repeating: 0, count: level+3)
        var mod_x = x
        var mod_y = y
        
        (0 ..< level + 3).forEach {
            (index) in
            let h_pow = pow(3.0, level + 2 - index).doubleValue
            if mod_x >= ceil(h_pow / 2.0) {
                code3_x[index] = 2
                mod_x -= h_pow
            } else if mod_x <= -ceil(h_pow / 2.0) {
                code3_x[index] = 0
                mod_x += h_pow
            } else {
                code3_x[index] = 1
            }
            
            if mod_y >= ceil(h_pow / 2.0) {
                code3_y[index] = 2
                mod_y -= h_pow
            } else if mod_y <= -ceil(h_pow / 2.0) {
                code3_y[index] = 0
                mod_y += h_pow
            } else {
                code3_y[index] = 1
            }
            
            if index == 2 && (z_loc_x == -180 || z_loc_x >= 0) {
                if code3_x[0] == 2 && code3_y[0] == 1 && code3_x[1] == code3_y[1] && code3_x[2] == code3_y[2] {
                    code3_x[0] = 1
                    code3_y[0] = 2
                } else if code3_x[0] == 1 && code3_y[0] == 0 && code3_x[1] == code3_y[1] && code3_x[2] == code3_y[2] {
                    code3_x[0] = 0
                    code3_y[0] = 1
                }
            }
        }
        
        var index = 0
        code3_x.forEach {
            (value) in
            let code3 = Int("\(value)\(code3_y[index])", radix: 3) ?? 0
            h_code += "\(code3)"
            index += 1
        }
        
        let h_2 = h_code.substring(from: 3)
        let h_1 = Int(h_code.substring(from: 0, length: 3)) ?? 0
        let h_a1 = Int(floor(Double(h_1 / 30)))
        let h_a2 = h_1 % 30
        
        return self.H_KEY.substring(from: h_a1, length: 1) +
            self.H_KEY.substring(from: h_a2, length: 1) + h_2
    }
}


extension GeoHex3 {
    class func getXY(min_lat: Double, min_lon: Double, max_lat: Double, max_lon: Double, level: Int, buffer: Bool) -> [XY]? {
        struct HexEdge {
            var l: Int
            var r: Int
            var t: Int
            var b: Int
        }
        
        let base_steps = (pow(3, level + 2) * 2).integerValue
        
        var min_lat = (min_lat > max_lat ? max_lat : min_lat)
        var max_lat = (min_lat < max_lat ? max_lat : min_lat)
        var min_lon = min_lon
        var max_lon = max_lon
        
        if buffer {
            let min_xy = self.loc2xy(latitude: min_lat, longitude: min_lon)
            let max_xy = self.loc2xy(latitude: max_lat, longitude: max_lon)
            let x_len = max_lon >= min_lon ? abs(max_xy.x - min_xy.x) : abs(self.H_BASE + max_xy.x - min_xy.x + self.H_BASE)
            let y_len = abs(max_xy.y - min_xy.y)
            
            let min_coord = self.xy2loc(x: (min_xy.x - x_len/2).truncatingRemainder(dividingBy: self.H_BASE*2), y: min_xy.y - y_len / 2)
            let max_coord = self.xy2loc(x: (max_xy.x - x_len/2).truncatingRemainder(dividingBy: self.H_BASE*2), y: max_xy.y - y_len / 2)
            
            min_lon = min_coord.longitude.truncatingRemainder(dividingBy: 360.0)
            max_lon = max_coord.longitude.truncatingRemainder(dividingBy: 360.0)
            min_lat = min_coord.latitude < -85.051128514 ? -85.051128514 : min_coord.latitude
            max_lat = max_coord.latitude > 85.051128514 ? 85.051128514 : max_coord.latitude
            min_lon = x_len * 2 >= self.H_BASE * 2 ? -180 : min_lon
            max_lon = x_len * 2 >= self.H_BASE * 2 ? 180 : max_lon
        }
        
        let zone_tl = self.getZone(latitude: max_lat, longitude: min_lon, level: level)
        let zone_bl = self.getZone(latitude: min_lat, longitude: min_lon, level: level)
        let zone_br = self.getZone(latitude: min_lat, longitude: max_lon, level: level)
        let zone_tr = self.getZone(latitude: max_lat, longitude: max_lon, level: level)
        
        let h_size = zone_br.hexSize
        
        let bl_xy = self.loc2xy(latitude: zone_bl.latitude, longitude: zone_bl.longitude)
        let bl_cl = self.xy2loc(x: bl_xy.x - h_size, y: bl_xy.y).longitude
        let bl_cr = self.xy2loc(x: bl_xy.x + h_size, y: bl_xy.y).longitude
        
        let br_xy = self.loc2xy(latitude: zone_br.latitude, longitude: zone_br.longitude)
        let br_cl = self.xy2loc(x: br_xy.x - h_size, y: br_xy.y).longitude
        let br_cr = self.xy2loc(x: br_xy.x + h_size, y: br_xy.y).longitude
        
        let s_steps = self.getXSteps(minlon: min_lon, maxlon: max_lon, min: zone_bl, max: zone_br)
        let w_steps = self.getYSteps(lon: min_lon, min: zone_bl, max: zone_tl)
        let n_steps = self.getXSteps(minlon: min_lon, maxlon: max_lon, min: zone_tl, max: zone_tr)
        let e_steps = self.getYSteps(lon: max_lon, min: zone_br, max: zone_tr)
        
        var edge: HexEdge = HexEdge(l: 0, r: 0, t: 0, b: 0)
        
        if s_steps == n_steps && s_steps >= base_steps {
            edge.l = 0
            edge.r = 0
        } else {
            if min_lon > 0 && zone_bl.longitude == -180 {
                let m_lon = min_lon - 360
                if bl_cr < m_lon {
                    edge.l = 1
                }
                if bl_cl > m_lon {
                    edge.l = -1
                }
            } else {
                if bl_cr < min_lon {
                    edge.l = 1
                }
                if bl_cl > min_lon {
                    edge.l = -1
                }
            }
            
            if max_lon > 0 && zone_br.longitude == -180 {
                let m_lon = max_lon - 360
                if br_cr < m_lon {
                    edge.r = 1
                }
                if br_cl > m_lon {
                    edge.r = -1
                }
            } else {
                if br_cr < max_lon {
                    edge.r = 1
                }
                if br_cl > max_lon {
                    edge.r = -1
                }
            }
        }
        
        if zone_bl.latitude > min_lat {
            edge.b += 1
        }
        if zone_tl.latitude > max_lat {
            edge.t += 1
        }
        
        let s_list = self.getX(min: zone_bl.position, xsteps: s_steps, edge: edge.b)
        let w_list = self.getY(min: zone_bl.position, ysteps: w_steps, edge: edge.l)
        
        guard let w_list_last = w_list.last, let s_list_last = s_list.last else {
            return nil
        }
        
        let tl_end = XY(x: w_list_last.x, y: w_list_last.y)
        let br_end = XY(x: s_list_last.x, y: s_list_last.y)
        let n_list = self.getX(min: tl_end, xsteps: n_steps, edge: edge.t)
        let e_list = self.getY(min: br_end, ysteps: e_steps, edge: edge.r)
        
        return self.merge(xys: s_list + w_list + n_list + e_list, level: level)
    }
    
    fileprivate class func getX(min: XY, xsteps: Int, edge: Int) -> [XY] {
        return (0 ..< xsteps).map {
            (index) in
            let index = Double(index)
            let x = edge != 0 ? min.x + floor(index / 2.0) : min.x + ceil(index / 2.0)
            let y = edge != 0 ? min.y + floor(index / 2.0) - index : min.y + ceil(index / 2.0) - index
            return XY(x: x, y: y)
        }
    }
    
    fileprivate class func getY(min: XY, ysteps: Double, edge: Int) -> [XY] {
        let steps_base = floor(ysteps)
        let steps_half = ysteps - steps_base
        
        return (0 ..< Int(steps_base)).reduce([XY]()) {
            (result, index) in
            var result = result
            let index = Double(index)
            let x = min.x + index
            let y = min.y + index
            
            result.append(XY(x: x, y: y))
            
            if edge != 0 {
                if steps_half == 0 && index == steps_base - 1 {
                } else {
                    let x = edge > 0 ? min.x + index + 1 : min.x + index
                    let y = edge < 0 ? min.y + index + 1 : min.y + index
                    result.append(XY(x: x, y: y))
                }
            }
            
            return result
        }
    }
    
    fileprivate class func getXSteps(minlon: Double, maxlon: Double, min: Zone, max: Zone) -> Int {
        let minsteps = Int(abs(min.x - min.y))
        let maxsteps = Int(abs(max.x - max.y))
        let code = min.code
        let base_steps = (pow(3.0, code.length) * 2.0).integerValue
        
        var steps = 0
        
        if min.longitude == -180 && max.longitude == -180 {
            if (minlon > maxlon && minlon * maxlon >= 0) || (minlon < 0 && maxlon > 0) {
                steps = base_steps
            } else {
                steps = 0
            }
        } else if abs(min.longitude - max.longitude) < 0.0000000001 {
            if min.longitude != -180 && minlon > maxlon {
                steps = base_steps
            } else {
                steps = 0
            }
        } else if min.longitude < max.longitude {
            if min.longitude <= 0 && max.longitude <= 0 {
                steps = minsteps - maxsteps
            }else if min.longitude <= 0 && max.longitude >= 0 {
                steps = minsteps + maxsteps
            }else if min.longitude >= 0 && max.longitude>=0 {
                steps = maxsteps - minsteps
            }
        } else if min.longitude > max.longitude {
            if min.longitude <= 0 && max.longitude <= 0 {
                steps = base_steps - maxsteps + minsteps
            }else if min.longitude >= 0 && max.longitude <= 0 {
                steps = base_steps-(minsteps + maxsteps)
            }else if min.longitude >= 0 && max.longitude >= 0 {
                steps = base_steps + maxsteps - minsteps
            }
        }
        
        return steps + 1
    }
    
    fileprivate class func getYSteps(lon: Double, min: Zone, max: Zone) -> Double {
        var min_x = min.x
        var min_y = min.y
        var max_x = max.x
        var max_y = max.y
        
        if lon > 0 {
            if min.longitude != -180 && max.longitude == -180 {
                max_x = max.y
                max_y = max.x
            }
            if min.longitude == -180 && max.longitude != -180 {
                min_x = min.y
                min_y = min.x
            }
        }
        
        let steps = abs(min_y - max_y)
        let half = abs(max_x - min_x) - abs(max_y - min_y)
        return steps + half * 0.5 + 1
    }
    
    fileprivate class func merge(xys: [XY], level: Int) -> [XY] {
        let xys = xys.sorted {
            (a, b) in
            return a.x > b.x ? false : a.x < b.x ? true : a.y < b.y ? false : true
        }
        
        var index = 0
        var mergeHash: [String:Bool] = [:]
        
        return xys.reduce([XY]()) {
            (result, xy) in
            var result = result
            if index == 0 {
                let inner_xy = self.adjustXY(x: xy.x, y: xy.y, level: level)
                let key = "\(inner_xy.x):\(inner_xy.y)"
                if mergeHash[key] == nil {
                    mergeHash[key] = true
                    result.append(inner_xy)
                }
            } else {
                let mergelen = self.mergeCheck(pre: xys[index - 1], next: xy)
                (0 ..< mergelen).forEach {
                    (j) in
                    let j = Double(j)
                    let inner_xy = self.adjustXY(x: xy.x, y: xy.y + j, level: level)
                    let key = "\(inner_xy.x):\(inner_xy.y)"
                    if mergeHash[key] == nil {
                        mergeHash[key] = true
                        result.append(inner_xy)
                    }
                }
            }
            index += 1
            return result
        }
    }
    
    fileprivate class func mergeCheck(pre: XY, next: XY) -> Int {
        if pre == next {
            return 0
        } else if pre.x != next.x {
            return 1
        } else {
            return Int(abs(next.y - pre.y))
        }
    }
}
