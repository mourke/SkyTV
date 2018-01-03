//
//  Region.swift
//  SkyTV
//
//  Copyright © 2018 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Foundation

enum Quality: String, Codable {
    case hd = "HD"
    case sd = "SD"
}

struct Region: Codable, Equatable {
    
    /// The user's current location, set on first app launch.
    static var current: Region! {
        get {
            if let data = UserDefaults.standard.data(forKey: "currentRegion") {
                return try? JSONDecoder().decode(Region.self, from: data)
            }
            return nil
        } set (region) {
            if let data = try? JSONEncoder().encode(region) {
                UserDefaults.standard.set(data, forKey: "currentRegion")
            }
        }
    }
    
    /// The name of the region.
    let name: String
    
    /// The quality in which the region broadcasts.
    let broadcastQuality: Quality
    
    /// The area code of the region.
    let bouquet: Int
    
    /// The sub-area code of the region.
    let subbouquet: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "n"
        case broadcastQuality = "t"
        case bouquet = "b"
        case subbouquet = "sb"
    }
    
}

func ==(_ lhs: Region, _ rhs: Region) -> Bool {
    return lhs.bouquet == rhs.bouquet && lhs.name == rhs.name && lhs.subbouquet == rhs.subbouquet
}
