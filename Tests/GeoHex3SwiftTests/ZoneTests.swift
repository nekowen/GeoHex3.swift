//
//  ZoneTests.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import XCTest
import CoreLocation

@testable import GeoHex3Swift

class ZoneTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProperty() {
        let coordinate1 = CLLocationCoordinate2D(latitude: 114514.0, longitude: 514114.0)
        let xy1 = XY(x: 1145141, y: 5141141)
        let zone1 = Zone(coordinate: coordinate1, xy: xy1, code: "XM123456789")
        
        XCTAssertEqual(zone1.position, xy1)
        XCTAssertEqual(zone1.coordinate, coordinate1)
        XCTAssertEqual(zone1.position, xy1)
        XCTAssertEqual(zone1.x, xy1.x)
        XCTAssertEqual(zone1.y, xy1.y)
        XCTAssertEqual(zone1.code, "XM123456789")
        XCTAssertEqual(zone1.level, 9)
    }
    
    func testPolygon() {
        let loc1 = CLLocationCoordinate2D(latitude: -76.99313665844154, longitude: 173.49609416243345)
        let xy1 = XY(x: -5023398, y: -46514720)
        let zone1 = Zone(coordinate: loc1, xy: xy1, code: "EU53225085622605")
        
        let data = [
            CLLocationCoordinate2D(latitude: -76.993136658441543, longitude: 173.49609137476466),
            CLLocationCoordinate2D(latitude: -76.993136115084724, longitude: 173.49609276859906),
            CLLocationCoordinate2D(latitude: -76.993136115084724, longitude: 173.49609555626782),
            CLLocationCoordinate2D(latitude: -76.993136658441543, longitude: 173.49609695010221),
            CLLocationCoordinate2D(latitude: -76.993137201798334, longitude: 173.49609555626782),
            CLLocationCoordinate2D(latitude: -76.993137201798334, longitude: 173.49609276859906),
        ]
        
        XCTAssertEqual(zone1.polygon, data)
    }
    
    func testHexSize() {
        let loc1 = CLLocationCoordinate2D(latitude: -76.99313665844154, longitude: 173.49609416243345)
        let xy1 = XY(x: -5023398, y: -46514720)
        let zone1 = Zone(coordinate: loc1, xy: xy1, code: "EU53225085622605")
        
        XCTAssertEqual(zone1.hexSize, 0.15516093424785285, accuracy: 0.000000001)
    }
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
