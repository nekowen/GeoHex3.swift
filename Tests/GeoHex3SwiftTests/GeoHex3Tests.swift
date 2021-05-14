//
//  GeoHex3Tests.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import XCTest
@testable import GeoHex3Swift

class GeoHex3SwiftTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    fileprivate func getJson<T>(fileName: String) -> T? {
        let bundle = Bundle(for: self.classForCoder)
        if let path = bundle.path(forResource: fileName, ofType: "json"),
            let jsonrawData = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let json = try? JSONSerialization.jsonObject(with: jsonrawData, options: []) {
            return json as? T
        }
        return nil
    }
    
    
    /// code -> XY
    fileprivate var code2xyJsonFileName: String {
        return "hex_v3.2_test_code2xy"
    }
    
    /// coordinate -> XY
    fileprivate var coord2xyJsonFileName: String {
        return "hex_v3.2_test_coord2xy"
    }
    
    /// code -> Hex
    fileprivate var code2hexJsonFileName: String {
        return "hex_v3.2_test_code2hex"
    }
    
    /// XY -> Hex
    fileprivate var xy2hexJsonFileName: String {
        return "hex_v3.2_test_xy2hex"
    }
    
    /// coordinate -> Hex
    fileprivate var coord2hexJsonFileName: String {
        return "hex_v3.2_test_coord2hex"
    }
    
    /// RECT -> XY
    fileprivate var rect2xysJsonFileName: String {
        return "hex_v3.2_test_rect2xys"
    }
    
    func testGetXYByCode() {
        let fileName = self.code2xyJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }
        
        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let code = detail[0] as? String, let x = detail[1] as? Int, let y = detail[2] as? Int {
                    let xy = GeoHex3.getXY(code: code)
                    XCTAssertEqual(xy.x, Double(x))
                    XCTAssertEqual(xy.y, Double(y))
                    return
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
    
    func testGetXYByLocation() {
        let fileName = self.coord2xyJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }
        
        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let level = detail[0] as? Int, let lat = detail[1] as? Double, let lon = detail[2] as? Double, let x = detail[3] as? Int, let y = detail[4] as? Int {
                    let xy = GeoHex3.getXY(latitude: lat, longitude: lon, level: level)
                    XCTAssertEqual(xy.x, Double(x))
                    XCTAssertEqual(xy.y, Double(y))
                    return
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
    
    func testGetZoneByCode() {
        let fileName = self.code2hexJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }

        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let code = detail[0] as? String, let lat = detail[1] as? Double, let lon = detail[2] as? Double {
                    let zone = GeoHex3.getZone(code: code)
                    XCTAssertEqual(zone.latitude, lat, accuracy: 0.000000001)
                    XCTAssertEqual(zone.longitude, lon, accuracy: 0.000000001)
                    XCTAssertEqual(zone.code, code)
                    return
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
    
    func testGetZoneByXY() {
        let fileName = self.xy2hexJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }
        
        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let level = detail[0] as? Int, let x = detail[1] as? Int, let y = detail[2] as? Int, let code = detail[3] as? String {
                    let zone = GeoHex3.getZone(xy: XY(x: Double(x), y: Double(y)), level: level)
                    XCTAssertEqual(zone.code, code)
                    XCTAssertEqual(zone.x, Double(x))
                    XCTAssertEqual(zone.y, Double(y))
                    XCTAssertEqual(zone.level, level)
                    return
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
    
    func testGetZoneByCoordinate() {
        let fileName = self.coord2hexJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }
        
        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let level = detail[0] as? Int, let lat = detail[1] as? Double, let lon = detail[2] as? Double, let code = detail[3] as? String {
                    let zone = GeoHex3.getZone(latitude: lat, longitude: lon, level: level)
                    XCTAssertEqual(zone.code, code)
                    return
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
    
    func testRectToXYs() {
        let fileName = self.rect2xysJsonFileName
        guard let json: NSArray = self.getJson(fileName: fileName) else {
            XCTFail("failed to load json \(fileName)")
            return
        }
        
        json.forEach {
            (value) in
            if let detail = value as? NSArray {
                if let south = detail[0] as? Double, let west = detail[1] as? Double, let north = detail[2] as? Double, let east = detail[3] as? Double, let level = detail[4] as? Int, let buffer = detail[5] as? Bool, let xys = detail[6] as? NSArray {
                    let xysmap: [XY] = xys.compactMap {
                        (xy) in
                        guard let xy = xy as? NSDictionary else {
                            return nil
                        }
                        guard let x = xy["x"] as? Int, let y = xy["y"] as? Int else {
                            return nil
                        }
                        return XY(x: Double(x), y: Double(y))
                    }
                    
                    if let calcXys = GeoHex3.getXY(min_lat: south, min_lon: west, max_lat: north, max_lon: east, level: level, buffer: buffer) {
                        XCTAssertEqual(calcXys.count, xysmap.count)
                        xysmap.forEach {
                            (value) in
                            XCTAssertNotNil(calcXys.firstIndex(of: value))
                        }
                        return
                    }
                }
            }
            XCTFail("failed to parse json \(fileName)")
        }
    }
}
