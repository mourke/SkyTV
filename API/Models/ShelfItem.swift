//
//  ShelfItem.swift
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
import struct CoreGraphics.CGBase.CGSize

struct ShelfItem: Node, Decodable {
    
    /// The programmes's name.
    let name: String
    
    /// The uuid of the programme.
    let id: String
    
    /// The type of the programme.
    let type: NodeType
    
    /// The channel in which the programme resides.
    let provider: String
    
    /// A short summary of the programme, if any.
    let synopsis: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "nodetype"
        case name = "t"
        case seriesId = "seriesuuid"
        case seasonId = "seasonuuid"
        case programmeId = "programmeuuid"
        case provider
        case synopsis = "sy"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(NodeType.self, forKey: .type)
        
        switch type {
        case .programme:
            id = try values.decode(String.self, forKey: .programmeId)
        case .series:
            id = try values.decode(String.self, forKey: .seriesId)
        default:
            throw NodeError.invalidType
        }
        
        provider = try values.decode(String.self, forKey: .provider)
        synopsis = try? values.decode(String.self, forKey: .synopsis)
    }
}
