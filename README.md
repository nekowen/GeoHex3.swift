# GeoHex3.swift

[![CI Status](http://img.shields.io/travis/nekowen/GeoHex3.swift.svg?style=flat)](https://travis-ci.org/nekowen/GeoHex3.swift)
[![Version](https://img.shields.io/cocoapods/v/GeoHex3.swift.svg?style=flat)](http://cocoapods.org/pods/GeoHex3.swift)
[![License](https://img.shields.io/cocoapods/l/GeoHex3.swift.svg?style=flat)](http://cocoapods.org/pods/GeoHex3.swift)
[![Platform](https://img.shields.io/cocoapods/p/GeoHex3.swift.svg?style=flat)](http://cocoapods.org/pods/GeoHex3.swift)

## Requirements

- iOS 9.0+
- Xcode 11.0+
- Swift 5.0+

If you want to use Swift3, Please use 0.1.x version.

## Installation

### CocoaPods

To install GeoHex3.swift by adding it to your `Podfile`:

```ruby
pod "GeoHex3.swift"
```

### Carthage

To install GeoHex3.swift by adding it to your `Cartfile`:

```
github "nekowen/GeoHex3.swift"
```

After build the framework by Carthage, add `GeoHex3Swift.framework` or `GeoHex3Swift.xcframework` to the `Frameworks and Libraries` in Xcode

### Swift Package Manager

To install GeoHex3.swift by adding it to your `Package.swift` or operating Xcode directly:

```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YOUR_APPLICATION_NAME",
    dependencies: [
        .package(url: "https://github.com/nekowen/GeoHex3.swift.git", from: "0.3.0")
    ]
)
```

## Example

To run the example, open `GeoHex3.swift.xcworkspace`  
The source code can be found under the Example directory.

## Usage

To get Hex Area from the coordinate, call the "getZone" method of the GeoHex3 class.

```swift
import GeoHex3Swift

let zone = GeoHex3.getZone(coordinate: COORDINATE, level: 7)
let hexcode = zone.code
```

Also, if the SouthWest and NorthEast coordinates are known, you can get the multiple areas it in range.

```swift
let zones = GeoHex3.getZone(southWest: SOUTHWEST_COORD, northEast: NORTHEAST_COORD, level: 7, buffer: false)

let areaHexcodes = zones.map { $0.code }
let areaPolygons = zones.map { $0.polygon }
```

## Author

nekowen, nekonyanowen@gmail.com

## License

GeoHex3.swift is available under the MIT license. See the LICENSE file for more info.

## Algorithm License

Copyright (c) 2009 @sa2da (http://twitter.com/sa2da)

GeoHex v3 http://geogames.net/geohex/v3
